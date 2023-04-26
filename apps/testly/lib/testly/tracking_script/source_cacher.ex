defmodule Testly.TrackingScript.SourceCacher do
  # use GenServer
  # require Logger

  # alias Testly.TrackingScript.{SourceDownloader}

  # @refresh_interval :timer.minutes(1)

  # defstruct [:script, :download]

  # def start_link(init_args \\ [], options \\ [name: __MODULE__]) do
  #   GenServer.start_link(__MODULE__, init_args, options)
  # end

  # def get_script(pid \\ __MODULE__) do
  #   GenServer.call(pid, :get_script)
  # end

  # @impl true
  # def init(init_args) do
  #   download = init_args[:download] || (&SourceDownloader.download/0)

  #   case download.() do
  #     {:ok, script} ->
  #       schedule_refresh()
  #       Logger.info("Start Testly.TrackingScript.SourceCacher")
  #       {:ok, %__MODULE__{script: script, download: download}}

  #     :error ->
  #       {:stop, :initial_download_failed}
  #   end
  # end

  # @impl true
  # def handle_call(:get_script, _from, %__MODULE__{script: script} = state) do
  #   {:reply, script, state}
  # end

  # @impl true
  # def handle_cast({:handle_download, {:ok, script}}, %__MODULE__{} = state) do
  #   Logger.info("Update source cache successed")
  #   schedule_refresh()
  #   {:noreply, %__MODULE__{state | script: script}}
  # end

  # @impl true
  # def handle_cast({:handle_download, :error}, %__MODULE__{} = state) do
  #   Logger.info("Update source cache failed")
  #   schedule_refresh()
  #   {:noreply, state}
  # end

  # @impl true
  # def handle_info(:refresh, %__MODULE__{download: download} = state) do
  #   self_pid = self()

  #   Task.start(fn ->
  #     # Don't block mailbox reading!
  #     GenServer.cast(self_pid, {:handle_download, download.()})
  #   end)

  #   {:noreply, state}
  # end

  # defp schedule_refresh do
  #   Process.send_after(
  #     self(),
  #     :refresh,
  #     @refresh_interval
  #   )
  # end
end
