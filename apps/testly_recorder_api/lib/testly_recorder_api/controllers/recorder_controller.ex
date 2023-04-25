defmodule TestlyRecorderAPI.RecorderController do
  use TestlyRecorderAPI, :controller
  require Logger

  @session_recordings Application.get_env(:testly, Testly.SessionRecordings)[:impl]
  @projects Application.get_env(:testly, Testly.Projects)[:impl]
  @split_tests Application.get_env(:testly, Testly.SplitTests)[:impl]
  @session_recordings_handler Application.get_env(:testly, Testly.SessionRecordingsHandler)[:impl]
  alias Testly.Feedback

  alias Testly.TrackingScript.{SourceDownloader, Script}

  def script(conn, %{"project_id" => project_id}) do
    project_id = String.replace(project_id, ".js", "", global: false)
    {:ok, script} = SourceDownloader.download()
    project = @projects.get_project(project_id)
    split_tests = @split_tests.get_active_split_tests(project)
    polls = Feedback.get_active_polls(project)

    {_hash, content} = Script.generate(script, project, split_tests, polls)

    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, content)
  end

  # Is used only for Beacon tracking
  # https://developer.mozilla.org/en-US/docs/Web/API/Beacon_API
  def track_session_recording(conn, %{"session_recording_id" => session_recording_id}) do
    {:ok, events, _conn} = read_body(conn)

    events = events |> Jason.decode!() |> ProperCase.to_snake_case()
    session_recording = @session_recordings.get_session_recording(session_recording_id)

    case @session_recordings_handler.track_session_recording(session_recording, events) do
      :ok ->
        Logger.info("http session_recording:track - success (#{session_recording_id})")

      {:error, :first_event_is_not_page_visited} ->
        Logger.warn(
          "session_recording:track - error (#{session_recording_id}) #{inspect(events, limit: :infinity)} first_event_is_not_page_visited"
        )

      {:error, changesets} ->
        Logger.warn("http session_recording:track - error (#{session_recording_id}) #{inspect(changesets)}")
    end

    send_resp(conn, 200, "")
  end
end
