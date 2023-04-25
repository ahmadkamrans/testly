defmodule Testly.SessionRecordingsHandler.Producer do
  use GenStage

  alias Testly.SessionEvents

  require Logger

  defmodule State do
    defstruct failed_to_process: []
  end

  def start_link(args, opts \\ []) do
    GenStage.start_link(
      __MODULE__,
      args,
      Keyword.merge(opts, name: {:via, Horde.Registry, {Testly.GlobalRegistry, __MODULE__}})
    )
  end

  def init(_) do
    Logger.info("Starting producer")

    :pg2.create(Testly.SessionRecordingsHandler.Consumer)

    {:producer, %State{}}
  end

  def handle_demand(demand, %State{failed_to_process: failed_to_process} = state) when demand > 0 do
    members = :pg2.get_members(Testly.SessionRecordingsHandler.Consumer)

    recordings_in_progress =
      multi_call(
        members,
        :get_session_recording_ids_in_progress
      )

    recordings_to_proceed =
      SessionEvents.get_not_processed_session_recording_ids(
        limit: demand,
        except_ids: recordings_in_progress ++ failed_to_process
      )

    Logger.info(
      "Failed to process recordings: #{length(failed_to_process)} \n" <>
        "Recordings in progress: #{inspect(recordings_in_progress)}\n" <>
        "Recordings to proceed: #{inspect(recordings_to_proceed)}\n" <>
        "Members: #{inspect(members)}"
    )

    {:noreply, recordings_to_proceed, state}
  end

  def handle_cast({:put_fail_to_process_recording_ids, ids}, %State{failed_to_process: failed_to_process} = state) do
    {:noreply, [], %State{state | failed_to_process: failed_to_process ++ ids}}
  end

  defp multi_call(consumers, msg, timeout \\ 5_000) do
    Enum.map(consumers, fn consumer ->
      Task.Supervisor.async_nolink(Testly.TaskSupervisor, fn ->
        try do
          GenServer.call(consumer, msg, timeout)
        catch
          :exit, info ->
            Logger.error("Producer multi_call timeout - #{inspect(info)}")
            []
        end
      end)
    end)
    |> Enum.map(&Task.await(&1, 20_000))
    |> List.flatten()
  end
end
