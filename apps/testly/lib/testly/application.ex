defmodule Testly.Application do
  @moduledoc """
  The Testly Application Service.

  The testly system business domain lives in this application.

  Exposes API to clients such as the `TestlyHome` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Horde.Supervisor,
       [
         name: Testly.DistributedSupervisor,
         strategy: :one_for_one,
         max_restarts: 100_000,
         max_seconds: 1
       ]},
      {Horde.Registry, [name: Testly.GlobalRegistry, keys: :unique]},
      {Cluster.Supervisor, [Application.get_env(:libcluster, :topologies), [name: Testly.ClusterSupervisor]]},
      supervisor(Testly.Repo, []),
      supervisor(Phoenix.PubSub.PG2, [
        Testly.PubSub,
        []
      ]),
      {Task.Supervisor, name: Testly.TaskSupervisor},
      Testly.Presence,
      {DynamicSupervisor, name: Testly.DynamicSupervisor, strategy: :one_for_one, max_restarts: 100_000, max_seconds: 1}
    ]

    result =
      Supervisor.start_link(
        children,
        strategy: :one_for_one,
        name: Testly.Supervisor
      )

    if Application.fetch_env!(:testly, Testly.SplitTests.VariationReportDbDumper)[:enabled] do
      Horde.Supervisor.start_child(
        Testly.DistributedSupervisor,
        Testly.SplitTests.VariationReportDbDumper
      )
    end

    if Application.get_env(:testly, Testly.TrackingScript)[:enable_supervisor] do
      Horde.Supervisor.start_child(
        Testly.DistributedSupervisor,
        Testly.TrackingScript.Supervisor
      )
    end

    if Application.get_env(:testly, Testly.SessionRecordingsHandler)[:enable_supervisor] do
      Horde.Supervisor.start_child(
        Testly.DistributedSupervisor,
        Testly.SessionRecordingsHandler.Producer
      )

      {:ok, _} = DynamicSupervisor.start_child(Testly.DynamicSupervisor, Testly.SessionRecordingsHandler.Consumer)
    end

    :ok =
      :telemetry.attach(
        "appsignal-ecto",
        [:testly, :repo, :query],
        &Appsignal.Ecto.handle_event/4,
        nil
      )

    nodes = [node()]
    :ok = Honeydew.start_queue(:accounts_queue, queue: {Honeydew.Queue.Mnesia, [disc_copies: nodes]})
    :ok = Honeydew.start_workers(:accounts_queue, Testly.Accounts.Worker, num: 10)

    :ok = Honeydew.start_queue(:split_tests_queue, queue: {Honeydew.Queue.Mnesia, [disc_copies: nodes]})
    :ok = Honeydew.start_workers(:split_tests_queue, Testly.SplitTests.Worker, num: 10)

    result
  end
end
