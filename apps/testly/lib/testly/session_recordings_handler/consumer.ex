defmodule Testly.SessionRecordingsHandler.Consumer do
  use GenStage

  require Logger

  alias Testly.SessionRecordingsHandler.AsyncHandler
  alias Testly.SessionRecordingsHandler.Producer

  @max_demand 100
  @ask_interval 5_000
  @producer {:via, Horde.Registry, {Testly.GlobalRegistry, Producer}}

  defmodule State do
    defstruct producers: [], session_recording_ids_in_progress: []
  end

  def start_link(opts \\ []) do
    GenStage.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    Logger.info("Consumer initializing")

    :pg2.create(__MODULE__)
    :pg2.join(__MODULE__, self())

    # We don't subscribe via `subscribe_to` cause
    # on Supervisor.start_child Consumer will not be restarted

    # !! lazy initialization here, to avoid a lot of Consumer failues per one time
    # when Producer is not available
    Process.send_after(self(), :do_subscribe, 5_000)

    {:consumer, %State{}, []}
  end

  def handle_subscribe(:producer, _opts, from, state) do
    # Returns manual as we want control over the demand,
    # to perform async task
    Logger.info("Consumer is subscribed to #{inspect(from)}")

    {
      :manual,
      ask_and_schedule(
        %State{
          state
          | producers: [from | state.producers]
        },
        from
      )
    }
  end

  def handle_events(session_recording_ids, _from, state) do
    Logger.info(fn -> "#{inspect(self())} Start proceeding #{inspect(session_recording_ids)}" end)

    Task.Supervisor.async_nolink(Testly.TaskSupervisor, fn ->
      {:ok, processed_ids, not_processed_ids} = AsyncHandler.handle(session_recording_ids)

      {:task_finished, processed_ids, not_processed_ids}
    end)

    {:noreply, [], %State{state | session_recording_ids_in_progress: session_recording_ids}}
  end

  def handle_info(:do_subscribe, state) do
    :ok = GenStage.async_subscribe(self(), to: @producer)

    {:noreply, [], state}
  end

  def handle_info({:ask, from}, state) do
    {:noreply, [], ask_and_schedule(state, from)}
  end

  def handle_info({_ref, {:task_finished, _processed_ids, []}}, state) do
    {:noreply, [], reset_ids_in_progress(state)}
  end

  def handle_info({_ref, {:task_finished, _processed_ids, not_processed_ids}}, state) do
    Logger.error("Failed to process ids: #{inspect(not_processed_ids)}")
    GenStage.cast(@producer, {:put_fail_to_process_recording_ids, not_processed_ids})

    {:noreply, [], reset_ids_in_progress(state)}
  end

  def handle_info({:DOWN, _, :process, _, :normal}, state) do
    # Task down message
    {:noreply, [], state}
  end

  def handle_call(:get_session_recording_ids_in_progress, _from, state) do
    {:reply, state.session_recording_ids_in_progress, [], state}
  end

  defp ask_and_schedule(%State{producers: producers, session_recording_ids_in_progress: []} = state, from) do
    Logger.info("Asking for demand #{inspect(from)}")

    producers
    |> Enum.find(&(&1 === from))
    |> GenStage.ask(@max_demand)

    Process.send_after(self(), {:ask, from}, @ask_interval)

    state
  end

  defp ask_and_schedule(%State{} = state, from) do
    Process.send_after(self(), {:ask, from}, @ask_interval)

    state
  end

  defp reset_ids_in_progress(%State{} = state) do
    %State{state | session_recording_ids_in_progress: []}
  end
end
