defmodule TestlyRecorderAPI.ProjectChannel do
  use Phoenix.Channel
  use Appsignal.Instrumentation.Decorators
  require Logger

  @session_recordings Application.get_env(:testly, Testly.SessionRecordings)[:impl]

  def join("project", _message, socket) do
    {:ok, socket}
  end

  @decorate channel_action()
  def handle_in("create:session_recording", %{"session_recording" => session_recording}, socket) do
    project_id = socket.assigns[:project_id]
    ip = socket.assigns[:ip]
    session_recording = ProperCase.to_snake_case(session_recording)

    session_recording_params = %{
      referrer: session_recording["referrer"],
      location: %{
        ip: ip
      },
      device: session_recording["device"]
    }

    case @session_recordings.create_session_recording(project_id, session_recording_params) do
      {:ok, session_recording} ->
        {:reply, {:ok, %{session_recording_id: session_recording.id}}, socket}

      {:error, changeset} ->
        Logger.warn("create_session_recording - validation errors: (#{inspect(changeset)})")
        {:reply, :error, socket}
    end
  end
end
