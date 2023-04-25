defmodule TestlyRecorderAPI.SessionRecordingChannelTest do
  use TestlyRecorderAPI.ChannelCase

  alias Testly.{Presence, SessionRecordingsMock}
  alias TestlyRecorderAPI.{ProjectSocket, SessionRecordingChannel}
  alias Testly.SessionRecordings.SessionRecording

  describe "online tracking" do
    test "works" do
      SessionRecordingsMock
      |> expect(:get_session_recording, fn id ->
        %SessionRecording{id: id}
      end)

      {:ok, _pid, socket} =
        socket(ProjectSocket)
        |> subscribe_and_join(SessionRecordingChannel, "session_recording:5")

      assert %{"5" => %{}} = Presence.list("session_recording:5")

      Process.unlink(socket.channel_pid)

      close(socket)

      assert Enum.empty?(Presence.list("session_recording:5"))
    end
  end
end
