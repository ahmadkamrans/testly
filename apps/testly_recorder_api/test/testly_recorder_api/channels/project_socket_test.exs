defmodule TestlyRecorderAPI.ProjectSocketTest do
  use TestlyRecorderAPI.ChannelCase

  alias Testly.ProjectsMock
  alias Testly.Projects.Project

  alias TestlyRecorderAPI.ProjectSocket

  test "takes x-forwarded-for IP when present" do
    ProjectsMock
    |> expect(:get_project, fn "123" ->
      %Project{is_recording_enabled: true}
    end)

    {:ok, socket} =
      connect(ProjectSocket, %{"project_id" => "123", "hostname" => "wow"}, %{
        x_headers: [{"x-forwarded-for", "1.1.1.1"}],
        peer_data: %{
          address: {127, 0, 0, 1}
        }
      })

    assert socket.assigns.ip === "1.1.1.1"
  end

  test "takes x-forwarded-for first ip when multiple present" do
    ProjectsMock
    |> expect(:get_project, fn "123" ->
      %Project{is_recording_enabled: true}
    end)

    {:ok, socket} =
      connect(ProjectSocket, %{"project_id" => "123", "hostname" => "wow"}, %{
        x_headers: [{"x-forwarded-for", "1.1.1.1, 162.158.94.12"}],
        peer_data: %{
          address: {127, 0, 0, 1}
        }
      })

    assert socket.assigns.ip === "1.1.1.1"
  end

  test "takes peer address when x-forwarded-for not present" do
    ProjectsMock
    |> expect(:get_project, fn "123" ->
      %Project{is_recording_enabled: true}
    end)

    {:ok, socket} =
      connect(ProjectSocket, %{"project_id" => "123", "hostname" => "wow"}, %{
        x_headers: [],
        peer_data: %{
          address: {127, 0, 0, 1}
        }
      })

    assert socket.assigns.ip === "127.0.0.1"
  end
end
