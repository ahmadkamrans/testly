defmodule Testly.TrackingScript.Supervisor do
  use Supervisor

  alias Testly.TrackingScript.{
    SourceCacher,
    Collector,
    UploaderSupervisor,
    Poller
  }

  def start_link(_args) do
    :global.trans(
      {__MODULE__, __MODULE__},
      fn ->
        case Supervisor.start_link(__MODULE__, :ok, name: {:global, __MODULE__}) do
          {:ok, pid} ->
            {:ok, pid}

          {:error, {:already_started, pid}} ->
            Process.link(pid)
            {:ok, pid}

          error ->
            error
        end
      end,
      Node.list(:connected),
      5
    )
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
