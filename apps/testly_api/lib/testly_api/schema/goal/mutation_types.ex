defmodule TestlyAPI.Schema.Goal.MutationTypes do
  use Absinthe.Schema.Notation

  import(Kronky.Payload, only: :functions)
  import(TestlyAPI.Schema.Payload)

  alias Testly.Goals
  alias Testly.Goals.PathGoal
  alias Testly.Authorizer
  alias Testly.Projects
  alias Testly.Projects.Project

  payload_object(:goal_payload, :goal)

  input_object :path_goal_step_params do
    field(:url, non_null(:string))
    field(:match_type, non_null(:page_matcher_match_type))
    field(:index, non_null(:integer))
  end

  input_object :goal_params do
    field(:id, :uuid4)
    field(:name, non_null(:string))
    field(:value, non_null(:decimal))
    field(:type, non_null(:goal_type))
    field(:path, list_of(non_null(:path_goal_step_params)))
  end

  object :goal_mutations do
    field :create_goal, type: :goal_payload do
      arg(:project_id, non_null(:uuid4))
      arg(:goal_params, non_null(:goal_params))

      resolve(fn %{goal_params: goal_params, project_id: project_id},
                 %{context: %{current_project_user: current_project_user}} ->
        auth_goal(%PathGoal{assoc_id: project_id}, :create, current_project_user, fn ->
          map_error_to_ok(Goals.create_goal(%Project{id: project_id}, goal_params))
        end)
      end)

      middleware(&build_payload/2)
    end

    field :update_goal, type: :goal_payload do
      arg(:id, non_null(:uuid4))
      arg(:goal_params, non_null(:goal_params))

      resolve(fn %{goal_params: goal_params, id: goal_id}, %{context: %{current_project_user: current_project_user}} ->
        goal = Goals.get_goal(%Project{}, goal_id)

        auth_goal(goal, :update, current_project_user, fn ->
          map_error_to_ok(Goals.update_goal(%Project{}, goal, goal_params))
        end)
      end)

      middleware(&build_payload/2)
    end

    field :delete_goal, :goal do
      arg(:id, non_null(:uuid4))

      resolve(fn %{id: goal_id}, %{context: %{current_project_user: current_project_user}} ->
        goal = Goals.get_goal(%Project{}, goal_id)

        auth_goal(goal, :delete, current_project_user, fn ->
          map_error_to_ok(Goals.delete_goal(%Project{}, goal))
        end)
      end)
    end
  end

  defp auth_goal(goal, action, current_project_user, on_success) do
    with {:ok, %PathGoal{}} <- if(goal, do: {:ok, goal}, else: {:error, :goal_not_found}),
         {:ok, %Project{} = project} <- get_project(goal.assoc_id),
         :ok <- Authorizer.authorize(action, goal, project, current_project_user) do
      on_success.()
    end
  end

  defp get_project(project_id) do
    case Projects.get_project(project_id) do
      nil -> {:error, :project_not_found}
      project -> {:ok, project}
    end
  end

  @spec map_error_to_ok({:error, any()} | {:ok, any()}) :: {:ok, any()}
  defp map_error_to_ok({:error, data}), do: {:ok, data}
  defp map_error_to_ok({:ok, data}), do: {:ok, data}
end
