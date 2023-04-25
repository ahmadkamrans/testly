# TODO: More tests to channels
# defmodule TestlyRecorderAPI.RecorderControllerTest do
#   use TestlyRecorderAPI.ConnCase
#   import Mox
#   import ExUnit.CaptureLog
#   require Logger

#   alias Testly.ProjectsMock
#   alias Testly.Projects.Project
#   alias Testly.SessionRecordingsMock
#   alias Testly.SessionRecordings.SessionRecording

#   # Make sure mocks are verified when the test exits
#   setup :verify_on_exit!

#   describe "settings/2" do
#     test "given only valid project_id", %{conn: conn} do
#       project_id = "uuid"

#       ProjectsMock
#       |> expect(:get_project, fn _project_id ->
#         %Project{is_recording_enabled: true}
#       end)

#       response =
#         conn
#         |> get("/settings", project_id: project_id)
#         |> json_response(200)

#       assert response == %{
#                "project" => %{
#                  "isRecordingEnabled" => true
#                },
#                "sessionRecording" => %{
#                  "isActive" => false
#                }
#              }
#     end

#     test "given valid project_id and session_recording_id", %{conn: conn} do
#       project_id = "uuid"
#       session_recording_id = "uuid2"

#       ProjectsMock
#       |> expect(:get_project, fn _project_id ->
#         %Project{is_recording_enabled: true}
#       end)

#       SessionRecordingsMock
#       |> expect(:get_session_recording, fn _session_recording_id ->
#         %SessionRecording{}
#       end)

#       response =
#         conn
#         |> get("/settings", project_id: project_id, session_recording_id: session_recording_id)
#         |> json_response(200)

#       assert response == %{
#                "project" => %{
#                  "isRecordingEnabled" => true
#                },
#                "sessionRecording" => %{
#                  "isActive" => true
#                }
#              }
#     end

#     test "given invalid project_id", %{conn: conn} do
#       fun = fn ->
#         project_id = "invalid uuid"

#         ProjectsMock
#         |> expect(:get_project, fn _project_id ->
#           nil
#         end)

#         response =
#           conn
#           |> get("/settings", project_id: project_id)

#         assert response.status == 400
#       end

#       assert capture_log(fun) =~ "project not found"
#     end
#   end

#   describe "create_session_recording/2" do
#     test "given valid params", %{conn: conn} do
#       project_id = "uuid"

#       params = %{
#         "session_recording" => %{}
#       }

#       # TODO: Pattern match arguments?
#       SessionRecordingsMock
#       |> expect(:create_session_recording, fn _session_recording_params ->
#         {:ok, %SessionRecording{id: "sr uuid"}}
#       end)

#       response =
#         conn
#         |> post("/projects/#{project_id}/session_recordings", params)
#         |> json_response(200)

#       assert response == %{
#                "sessionRecordingId" => "sr uuid"
#              }
#     end
#   end

#   @tag :skip
#   describe "create_events/2" do
#     test "valid params", %{conn: conn} do
#       session_recording_id = "uuid"

#       events = [
#         %{}
#       ]

#       SessionRecordingsMock
#       |> expect(:create_events, fn _session_recording_id, _events ->
#         {:ok, 1}
#       end)

#       response = post(conn, "/events", session_recording_id: session_recording_id, events: events)

#       assert response.status == 204
#     end
#   end
# end
