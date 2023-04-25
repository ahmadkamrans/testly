defmodule Testly.Authorizer do
  alias Testly.Projects.Project
  alias Testly.Projects.User, as: ProjectUser
  alias Testly.Accounts.User, as: AccountUser
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.Goals.PathGoal

  def authorize(:access, %Project{user_id: user_id}, %ProjectUser{id: id}) when user_id == id, do: :ok
  def authorize(:access, %Project{}, %ProjectUser{}), do: {:error, :unauthorized}

  def authorize(:delete, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, project, user)

  def authorize(:show, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, project, user)

  def authorize(:update, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, project, user)

  def authorize(:update_password, %AccountUser{} = user, %AccountUser{} = current_user),
    do: authorize(:access, user, current_user)

  def authorize(:update, %AccountUser{} = user, %AccountUser{} = current_user),
    do: authorize(:access, user, current_user)

  def authorize(:access, %AccountUser{id: user_id}, %AccountUser{id: current_user_id}) when user_id === current_user_id,
    do: :ok

  def authorize(:access, %AccountUser{}, %AccountUser{}), do: {:error, :unauthorized}

  def authorize(
        :access,
        %SessionRecording{project_id: session_recording_project_id},
        %Project{id: project_id, user_id: project_user_id},
        %ProjectUser{id: user_id}
      )
      when session_recording_project_id === project_id and project_user_id === user_id,
      do: :ok

  def authorize(:access, %SessionRecording{}, %Project{}, %ProjectUser{}), do: {:error, :unauthorized}

  def authorize(:show, %SessionRecording{} = session_recording, %Project{} = project, %ProjectUser{} = project_user),
    do: authorize(:access, session_recording, project, project_user)

  def authorize(
        :access,
        %PathGoal{assoc_id: goal_project_id},
        %Project{id: project_id, user_id: project_user_id},
        %ProjectUser{id: user_id}
      )
      when goal_project_id === project_id and project_user_id === user_id,
      do: :ok

  def authorize(:access, %PathGoal{}, %Project{}, %ProjectUser{}), do: {:error, :unauthorized}

  def authorize(:show, %PathGoal{} = goal, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:create, %PathGoal{} = goal, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:update, %PathGoal{} = goal, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, goal, project, user)

  def authorize(:delete, %PathGoal{} = goal, %Project{} = project, %ProjectUser{} = user),
    do: authorize(:access, goal, project, user)
end
