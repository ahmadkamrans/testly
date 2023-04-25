defmodule TestlyAPI.SessionRecordingResolver do
  use TestlyAPI.Resolver
  alias Testly.{Authorizer, SessionRecordings, SplitTests, SessionEvents, Feedback}
  alias Testly.SessionRecordings.{SessionRecording, Device}
  alias Testly.Projects.Project
  alias Testly.SessionRecordings.Filter, as: SessionRecordingsFilter

  def session_recordings(%Project{id: project_id} = _project, %{page: page, per_page: per_page} = args, _resolution) do
    filter = struct(SessionRecordingsFilter, args[:filter] || %{})

    {:ok,
     %{
       project_id: project_id,
       filter: filter,
       page: page,
       per_page: per_page,
       total_count: SessionRecordings.get_project_session_recordings_count(project_id, filter)
     }}
  end

  def session_recording(%Project{} = project, %{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, %SessionRecording{} = session_recording} <- {:ok, SessionRecordings.get_session_recording(id)},
         :ok <- Authorizer.authorize(:show, session_recording, project, current_user),
         do: {:ok, session_recording}
  end

  def split_test(%{split_test_id: split_test_id}, _args, _resolution) do
    {:ok, SplitTests.get_split_test(split_test_id)}
  end

  def os(%Device{} = device, _args, _resolution) do
    {:ok,
     %{
       name: device.os_name,
       version: device.os_version
     }}
  end

  def browser(%Device{} = device, _args, _resolution) do
    {:ok,
     %{
       name: device.browser_name,
       version: device.browser_version
     }}
  end

  def feedback_poll_responses(session_recording, _args, _resolution) do
    {:ok, Feedback.get_responses(session_recording)}
  end

  def split_test_edges(
        %SessionRecording{
          split_test_goals: split_test_goals,
          split_test_variations: split_test_variations
        },
        _args,
        _resolution
      ) do
    grouped_goals = Enum.group_by(split_test_goals, & &1.split_test_id)
    grouped_variations = Enum.group_by(split_test_variations, & &1.split_test_id)

    {:ok,
     for {split_test_id, [variation]} <- grouped_variations do
       %{
         split_test_id: split_test_id,
         visited_variation: variation,
         converted_goals: Map.get(grouped_goals, split_test_id, [])
       }
     end}
  end

  def events(%SessionRecording{id: id}, _args, _resolution) do
    {:ok, SessionEvents.get_raw_events(id)}
  end
end
