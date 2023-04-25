defmodule TestlyRecorderAPI.SessionRecordingChannel do
  use Phoenix.Channel
  use Appsignal.Instrumentation.Decorators
  require Logger

  alias Testly.Presence
  # alias Testly.SessionRecordings
  alias Testly.SplitTests
  alias Testly.SessionRecordings.SessionRecording

  @session_recordings Application.get_env(:testly, Testly.SessionRecordings)[:impl]
  @session_recordings_handler Application.get_env(:testly, Testly.SessionRecordingsHandler)[:impl]

  def join("session_recording:" <> session_recording_id, _message, socket) do
    # project_id = socket.assigns[:project_id]
    # TODO: check that session recording belongs to project

    case @session_recordings.get_session_recording(session_recording_id) do
      %SessionRecording{} ->
        send(self(), :after_join)
        {:ok, assign(socket, :session_recording_id, session_recording_id)}

      nil ->
        {:error, %{reason: "bad session recording"}}
    end
  end

  @decorate channel_action()
  def handle_in(
        "visit_split_test_variation",
        %{"split_test_id" => split_test_id, "variation_id" => variation_id},
        socket
      ) do
    # TODO: Session recording must be ready
    session_recording_id = socket.assigns[:session_recording_id]

    split_test = SplitTests.get_split_test(split_test_id)
    session_recording = @session_recordings.get_session_recording(session_recording_id)

    if split_test.status == :active do
      SplitTests.visit_split_test_variation(split_test, variation_id, session_recording)
    end

    {:reply, :ok, socket}
  end

  @decorate channel_action()
  def handle_in("track", %{"events" => events}, socket) do
    events = ProperCase.to_snake_case(events)
    session_recording_id = socket.assigns[:session_recording_id]

    Honeybadger.context(session_recording_id: session_recording_id, events: events)

    session_recording = @session_recordings.get_session_recording(session_recording_id)

    case @session_recordings_handler.track_session_recording(session_recording, events) do
      :ok ->
        Logger.info("session_recording:track - success (#{session_recording_id})")
        {:reply, :ok, socket}

      {:error, :first_event_is_not_page_visited} ->
        Logger.warn("session_recording:track - error (#{session_recording_id}) first_event_is_not_page_visited")
        {:reply, :error, socket}

      {:error, changesets} ->
        Logger.warn("session_recording:track - error (#{session_recording_id}) #{inspect(changesets)}")
        {:reply, :error, socket}
        # {:stop, :shutdown, socket}
    end
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.session_recording_id, %{
      online_at: System.system_time(:millisecond)
    })

    {:noreply, socket}
  end
end
