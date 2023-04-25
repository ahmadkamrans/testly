defmodule Testly.SessionRecordings.CleanerTest do
  use Testly.DataCase, async: true
  import Testly.DataFactory

  alias Testly.SessionRecordings.{Cleaner, SessionRecording}

  test "works" do
    project = insert(:project)

    %{id: s_r1_id} =
      insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -3))

    s_r2 = insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -31))

    Cleaner.handle_info(:clean, nil)

    assert %SessionRecording{id: ^s_r1_id} = Repo.get(SessionRecording, s_r1_id)
    assert Repo.get(SessionRecording, s_r2.id) === nil
  end
end
