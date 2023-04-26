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
      {Phoenix.PubSub, name: Testly.PubSub},
      {Cluster.Supervisor, [Application.get_env(:libcluster, :topologies), [name: Testly.ClusterSupervisor]]},
      supervisor(Testly.Repo, []),
      {Task.Supervisor, name: Testly.TaskSupervisor},
      Testly.Presence,
      {
        DynamicSupervisor,
        name: Testly.DynamicSupervisor,
        strategy: :one_for_one,
        max_restarts: 100_000,
        max_seconds: 1
       },
      {
        DynamicSupervisor,
        name: Testly.DynamicSessionsSupervisor,
        strategy: :one_for_one,
        max_restarts: 100_000,
        max_seconds: 1
      }
    ]

    # children =
    #   if(Application.get_env(:testly, Testly.TrackingScript)[:enable_supervisor],
    #     do: children ++ [{Testly.TrackingScript.Supervisor, []}],
    #     else: children
    #   )

    result =
      Supervisor.start_link(
        children,
        strategy: :one_for_one,
        name: Testly.Supervisor
      )

    # if Application.fetch_env!(:testly, Testly.SplitTests.VariationReportDbDumper)[:enabled] do
    #   {:ok, _} = DynamicSupervisor.start_child(Testly.DynamicSupervisor, Testly.SplitTests.VariationReportDbDumper)
    # end

    # if Application.fetch_env!(:testly, Testly.SessionRecordings.Cleaner)[:enabled] do
    #   {:ok, _} = DynamicSupervisor.start_child(Testly.DynamicSupervisor, Testly.SessionRecordings.Cleaner)
    # end

    # if Application.fetch_env!(:testly, Testly.Heatmaps.ViewsCleaner)[:enabled] do
    #   {:ok, _} = DynamicSupervisor.start_child(Testly.DynamicSupervisor, Testly.Heatmaps.ViewsCleaner)
    # end

    # if Application.get_env(:testly, Testly.SessionRecordingsHandler)[:enable_supervisor] do
    #   {:ok, _} = DynamicSupervisor.start_child(
    #     Testly.DynamicSessionsSupervisor, Testly.SessionRecordingsHandler.Consumer
    #   )

    #   {:ok, _} = DynamicSupervisor.start_child(
    #     Testly.DynamicSessionsSupervisor, Testly.SessionRecordingsHandler.Producer
    #   )
    # end

    result
  end
end
