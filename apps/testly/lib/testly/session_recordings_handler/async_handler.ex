defmodule Testly.SessionRecordingsHandler.AsyncHandler do
  alias Testly.SessionRecordings
  alias Testly.SessionRecordingsHandler

  @max_concurrency 10

  # It will ignore if it failed to proceed session recording
  def handle(session_recordings_ids) do
    processed_ids =
      Task.Supervisor.async_stream_nolink(
        Testly.TaskSupervisor,
        session_recordings_ids,
        fn session_recording_id ->
          session_recording = SessionRecordings.get_session_recording(session_recording_id)
          SessionRecordingsHandler.process_session_recording(session_recording)

          {:ok, session_recording_id}
        end,
        timeout: :infinity,
        max_concurrency: @max_concurrency
      )
      |> Stream.filter(&match?({:ok, {:ok, _}}, &1))
      |> Stream.map(fn {:ok, {:ok, id}} -> id end)
      |> Enum.to_list()

    not_processed_ids = session_recordings_ids -- processed_ids

    {:ok, processed_ids, not_processed_ids}
  end
end
