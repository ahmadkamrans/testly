defmodule Testly.TrackingScript.Collector do
  @moduledoc """
    The Collector Producer. Collects scripts that need to be uploaded.
  """
  use GenStage
  require Logger

  def start_link(args \\ [], opts \\ [name: __MODULE__]) do
    GenStage.start_link(__MODULE__, args, opts)
  end

  def upload(pid \\ __MODULE__, script)

  def upload(pid, {_name, _content} = script) do
    GenServer.cast(pid, {:upload, [script]})
  end

  def upload(pid, scripts) do
    GenServer.cast(pid, {:upload, scripts})
  end

  @impl true
  def init(_args) do
    Logger.info("Start Testly.TrackingScript.Collector")
    {:producer, []}
  end

  @impl true
  def handle_cast({:upload, scripts}, state) do
    {:noreply, scripts, state}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
