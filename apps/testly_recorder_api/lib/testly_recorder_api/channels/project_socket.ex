defmodule TestlyRecorderAPI.ProjectSocket do
  use Phoenix.Socket
  require Logger
  alias Testly.Projects.Project

  @projects Application.get_env(:testly, Testly.Projects)[:impl]

  ## Channels
  channel("session_recording:*", TestlyRecorderAPI.SessionRecordingChannel)
  channel("project", TestlyRecorderAPI.ProjectChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"project_id" => project_id, "hostname" => _hostname}, socket, connect_info) do
    # :error
    with %Project{is_recording_enabled: true} = project <- @projects.get_project(project_id) do
      # TODO: CHECK DOMAIN
      ip =
        with {_key, value} <- Enum.find(connect_info.x_headers, fn {key, _v} -> key === "x-forwarded-for" end) do
          value
          |> String.split(",")
          |> List.first()
        else
          _ -> connect_info.peer_data.address |> :inet.ntoa() |> to_string()
        end

      socket =
        socket
        |> assign(:project_id, project.id)
        |> assign(:ip, ip)

      {:ok, socket}
    else
      nil ->
        Logger.warn("ProjectSocket: Invalid project_id - #{project_id}")
        :error

      %Project{is_recording_enabled: false} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TestlyRecorderAPI.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
