defmodule Testly.TrackingScript.Supervisor do
  use Supervisor

  alias Testly.TrackingScript.{
    SourceCacher,
    Collector,
    UploaderSupervisor,
    Poller
  }

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {SourceCacher, []},
      {Collector, []},
      {UploaderSupervisor, []},
      {Poller, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
