defmodule TestlyAPI.Schema.GoalTypes do
  use Absinthe.Schema.Notation

  alias Testly.{Goals, Authorizer}
  alias Testly.Projects.Project
  alias Testly.Goals.PathGoal

  # Taken from Testly.Goals.GoalTypeEnum
  enum(:goal_type,
    values: [
      :path
    ]
  )

  union :goal do
    types([:path_goal])

    resolve_type(fn
      _, _ -> :path_goal
    end)
  end

  # object :split_test_variation_conversion_rate_by_date do
  #   field :date, non_null(:datetime)
  #   field :conversion_rate, non_null(:float)
  # end

  # object :goal_conversions_stats do
  #   field :conversion_rate, non_null(:float)
  #   field :conversions_count, non_null(:integer)
  #   field :visits_count, non_null(:integer)
  #   field :improvement, :integer
  #   field :is_winner, non_null(:boolean)
  #   field :revenue, non_null(:float)
  #   # field :goal_id, non_null(:uuid4)
  #   field :variation_id, non_null(:uuid4)

  #   field :rates_by_date, non_null(list_of(non_null(:split_test_variation_conversion_rate_by_date)))
  # end

  interface :goal_entity do
    field(:id, non_null(:uuid4))
    field(:type, non_null(:goal_type))
    field(:name, non_null(:string))
    field(:value, non_null(:decimal))
    field(:created_at, non_null(:datetime))
    # field(:conversions_count, non_null(:integer))

    field :conversions_count, non_null(:integer) do
      resolve(fn goal, _args, _resolution ->
        {:ok, Enum.count(goal.conversions)}
      end)
    end

    # field :stats, non_null(list_of()) do
    # end

    resolve_type(fn
      _, _ -> :path_goal
    end)
  end

  object :goals_connection do
    field :nodes, non_null(list_of(non_null(:goal))) do
      resolve(fn %{project_id: project_id}, _args, _resolution ->
        {:ok, Goals.get_goals(%Project{id: project_id})}
      end)
    end

    field(:total_records, non_null(:integer))
  end

  object :goal_queries do
    field :goals, non_null(:goals_connection) do
      resolve(fn %Project{id: project_id} = project, _args, _resolution ->
        {:ok,
         %{
           project_id: project_id,
           total_records: Goals.get_goals_count(project),
           # TODO: I think we need to remove this field?
           session_recordings_with_goals_count: 0
         }}
      end)
    end

    field :goal, :goal do
      arg(:id, non_null(:uuid4))

      resolve(fn %Project{} = project, %{id: id}, %{context: %{current_project_user: current_project_user}} ->
        with {:ok, %PathGoal{} = goal} <- {:ok, Goals.get_goal(project, id)},
             :ok <- Authorizer.authorize(:show, goal, project, current_project_user) do
          {:ok, Goals.get_goal(project, id)}
        end
      end)
    end
  end
end
