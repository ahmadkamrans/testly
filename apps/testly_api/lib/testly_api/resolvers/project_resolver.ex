defmodule TestlyAPI.ProjectResolver do
  use TestlyAPI.Resolver

  alias Testly.{
    Authorizer,
    Projects,
    SessionRecordings
  }

  alias Testly.Projects.Project
  alias Testly.Accounts.User

  def relevant_project(%User{id: user_id}, _args, _resolution) do
    {:ok, Projects.get_relevant_project(user_id)}
  end

  def projects(%User{id: user_id}, _args, _resolution) do
    {:ok,
     %{
       nodes: Projects.get_projects(user_id),
       total_count: 0
     }}
  end

  def project(_parent, %{id: id}, _resolution) do
    {:ok, Projects.get_project(id)}
  end

  def create_project(%{project_params: project_params}, %{context: %{current_user: current_user}}) do
    case Projects.create_project(current_user.id, project_params) do
      {:ok, %Project{} = project} -> {:ok, project}
      {:error, ch} -> {:ok, ch}
    end
  end

  def update_project(%{project_params: project_params, id: project_id}, %{
        context: %{current_user: current_user}
      }) do
    project = Projects.get_project(project_id)

    with {:ok, _} <- if(project, do: {:ok, project}, else: {:error, :not_found}),
         :ok <- Authorizer.authorize(:update, project, current_user) do
      case Projects.update_project(project, project_params) do
        {:ok, %Project{} = project} -> {:ok, project}
        {:error, ch} -> {:ok, ch}
      end
    else
      error -> error
    end
  end

  def delete_project(%{id: project_id}, %{context: %{current_user: current_user}}) do
    project = Projects.get_project(project_id)

    with {:ok, _} <- if(project, do: {:ok, project}, else: {:error, :not_found}),
         :ok <- Authorizer.authorize(:delete, project, current_user),
         :ok <- Projects.delete_project(project) do
      {:ok, project}
    else
      error -> error
    end
  end

  def project_state(
        %Project{id: project_id, created_at: created_at} = _project,
        _args,
        _resolution
      ) do
    records_count = SessionRecordings.get_project_session_recordings_count(project_id)

    {:ok,
     case({records_count, Timex.diff(Timex.now(), created_at, :hours) > 1}) do
       {0, true} -> :code_may_not_be_installed
       {0, false} -> :waiting_for_first_visit
       _ -> :active
     end}
  end
end
