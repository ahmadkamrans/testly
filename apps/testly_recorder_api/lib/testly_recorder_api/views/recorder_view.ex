defmodule TestlyRecorderAPI.RecorderView do
  use TestlyRecorderAPI, :view

  alias Testly.SessionRecordings.SessionRecording

  def render("split_test_settings.json", %{variation: nil}) do
    %{}
  end

  def render("split_test_settings.json", %{variation: variation}) do
    %{
      split_test_id: variation.split_test_id,
      variation_for_visit: %{
        id: variation.id,
        url: variation.url
      }
    }
  end

  def render("settings.json", %{project: project, session_recording: %SessionRecording{}}) do
    %{
      project: %{
        is_recording_enabled: project.is_recording_enabled
      },
      session_recording: %{
        is_active: true
      }
    }
  end

  def render("settings.json", %{project: project, session_recording: nil}) do
    %{
      project: %{
        is_recording_enabled: project.is_recording_enabled
      },
      session_recording: %{
        is_active: false
      }
    }
  end

  def render("create_session_recording.json", %{session_recording: session_recording}) do
    %{
      session_recording_id: session_recording.id
    }
  end
end
