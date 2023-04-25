defmodule TestlyAPI.Schema.GoalTypes do
  use TestlyAPI.Schema.Notation

  alias TestlyAPI.{GoalResolver}
  alias Testly.Goals.Goal

  # Taken from Testly.Goals.GoalTypeEnum
  enum(:goal_type,
    values: [
      :path
    ]
  )

  interface :goal_entity do
    field(:id, non_null(:uuid4))
    field(:type, non_null(:goal_type))
    field(:name, non_null(:string))
    field(:value, non_null(:decimal))
    field(:created_at, non_null(:datetime))
    field :conversions_count, non_null(:integer)

    resolve_type(fn
      %Goal{type: :path}, _ -> :path_goal
    end)
  end

  union :goal do
    types([:path_goal])

    resolve_type(fn
      %Goal{type: :path}, _ -> :path_goal
    end)
  end

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

  object :path_goal do
    interface(:goal_entity)
    field(:id, non_null(:uuid4))
    field(:type, non_null(:goal_type))
    field(:name, non_null(:string))
    field(:value, non_null(:decimal))
    field(:created_at, non_null(:datetime))

    field :conversions_count, non_null(:integer) do
      resolve(&GoalResolver.conversions_count/3)
    end

    field :path, non_null(list_of(non_null(:path_goal_step)))
  end

  object :path_goal_step do
    field(:url, non_null(:string))
    field(:match_type, non_null(:page_matcher_match_type))
    field(:index, non_null(:integer))
  end

  object :goal_connection do
    field :nodes, non_null(list_of(non_null(:goal)))
    field :total_count, non_null(:integer)
  end

  object :goal_queries do
    field :goals, non_null(:goal_connection) do
      resolve(&GoalResolver.goal_connection/3)
    end

    field :goal, :goal do
      arg(:id, non_null(:uuid4))
      resolve(&GoalResolver.goal/3)
    end
  end

  object :goal_mutations do
    field :create_goal, type: :goal_payload do
      arg(:project_id, non_null(:uuid4))
      arg(:goal_params, non_null(:goal_params))
      resolve(&GoalResolver.create_goal/2)
      middleware(&build_payload/2)
    end

    field :update_goal, type: :goal_payload do
      arg(:id, non_null(:uuid4))
      arg(:goal_params, non_null(:goal_params))
      resolve(&GoalResolver.update_goal/2)
      middleware(&build_payload/2)
    end

    field :delete_goal, :goal do
      arg(:id, non_null(:uuid4))
      resolve(&GoalResolver.delete_goal/2)
    end
  end
end
