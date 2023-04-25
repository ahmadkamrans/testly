defmodule Testly.Authorizer do
  alias Testly.Projects.Project
  alias Testly.Accounts.User
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.Goals.Goal

  def authorize(:access, %Project{user_id: user_id}, %User{id: id}) when user_id == id, do: :ok
  def authorize(:access, %Project{}, %User{}), do: {:error, :unauthorized}

  def authorize(:delete, %Project{} = project, %User{} = user),
    do: authorize(:access, project, user)

  def authorize(:show, %Project{} = project, %User{} = user),
    do: authorize(:access, project, user)

  def authorize(:update, %Project{} = project, %User{} = user),
    do: authorize(:access, project, user)

  def authorize(:update_password, %User{} = user, %User{} = current_user),
    do: authorize(:access, user, current_user)

  def authorize(:update, %User{} = user, %User{} = current_user),
    do: authorize(:access, user, current_user)

  def authorize(:access, %User{id: user_id}, %User{id: current_user_id}) when user_id === current_user_id,
    do: :ok

  def authorize(:access, %User{}, %User{}), do: {:error, :unauthorized}

  def authorize(
        :access,
        %SessionRecording{project_id: session_recording_project_id},
        %Project{id: project_id, user_id: project_user_id},
        %User{id: user_id}
      )
      when session_recording_project_id === project_id and project_user_id === user_id,
      do: :ok

  def authorize(:access, %SessionRecording{}, %Project{}, %User{}), do: {:error, :unauthorized}

  def authorize(:show, %SessionRecording{} = session_recording, %Project{} = project, %User{} = user),
    do: authorize(:access, session_recording, project, user)

  def authorize(
        :access,
        %Goal{project_id: goal_project_id},
        %Project{id: project_id, user_id: project_user_id},
        %User{id: user_id}
      )
      when goal_project_id === project_id and project_user_id === user_id,
      do: :ok

  def authorize(:access, %Goal{}, %Project{}, %User{}), do: {:error, :unauthorized}

  def authorize(:show, %Goal{} = goal, %Project{} = project, %User{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:create, %Goal{} = goal, %Project{} = project, %User{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:update, %Goal{} = goal, %Project{} = project, %User{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:delete, %Goal{} = goal, %Project{} = project, %User{} = user),
    do: authorize(:access, goal, project, user)
end
