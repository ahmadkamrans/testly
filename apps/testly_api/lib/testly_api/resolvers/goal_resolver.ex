defmodule TestlyAPI.GoalResolver do
  use TestlyAPI.Resolver
  alias Testly.{Goals, Authorizer, Projects}
  alias Testly.Projects.Project
  alias Testly.Goals.Goal

  def conversions_count(goal, _args, _resolution) do
    {:ok, Enum.count(goal.conversions)}
  end

  def goals(%{project_id: project_id}, _args, _resolution) do
    {:ok, Goals.get_goals(%Project{id: project_id})}
  end

  def goal(%Project{} = project, %{id: id}, %{context: %{current_user: current_user}}) do
    with %Goal{} = goal <- Goals.get_goal(id),
         :ok <- Authorizer.authorize(:show, goal, project, current_user) do
      {:ok, Goals.get_goal(project, id)}
    end
  end

  def goal_connection(%Project{} = project, _args, _resolution) do
    {:ok,
     %{
       nodes: Goals.get_goals(project),
       total_count: Goals.get_goals_count(project)
     }}
  end

  def create_goal(%{goal_params: goal_params, project_id: project_id}, %{context: %{current_user: current_user}}) do
    auth_goal(%Goal{project_id: project_id}, :create, current_user, fn ->
      map_error_to_ok(Goals.create_goal(%Project{id: project_id}, goal_params))
    end)
  end

  def update_goal(%{goal_params: goal_params, id: goal_id}, %{context: %{current_user: current_user}}) do
    goal = Goals.get_goal(%Project{}, goal_id)

    auth_goal(goal, :update, current_user, fn ->
      map_error_to_ok(Goals.update_goal(%Project{}, goal, goal_params))
    end)
  end

  def delete_goal(%{id: goal_id}, %{context: %{current_user: current_user}}) do
    goal = Goals.get_goal(%Project{}, goal_id)

    auth_goal(goal, :delete, current_user, fn ->
      map_error_to_ok(Goals.delete_goal(goal))
    end)
  end

  defp auth_goal(goal, action, current_user, on_success) do
    with {:ok, %Goal{}} <- if(goal, do: {:ok, goal}, else: {:error, :goal_not_found}),
         {:ok, %Project{} = project} <- get_project(goal.assoc_id),
         :ok <- Authorizer.authorize(action, goal, project, current_user) do
      on_success.()
    end
  end

  defp get_project(project_id) do
    case Projects.get_project(project_id) do
      nil -> {:error, :project_not_found}
      project -> {:ok, project}
    end
  end
end
