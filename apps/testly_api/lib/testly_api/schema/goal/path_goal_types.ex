defmodule TestlyAPI.Schema.Goal.PathGoalTypes do
  use Absinthe.Schema.Notation

  object :path_goal do
    field(:id, non_null(:uuid4))
    field(:type, non_null(:goal_type))
    field(:name, non_null(:string))
    field(:value, non_null(:decimal))
    field(:created_at, non_null(:datetime))

    field :conversions_count, non_null(:integer) do
      resolve(fn goal, _args, _resolution ->
        {:ok, Enum.count(goal.conversions)}
      end)
    end

    # field :conversions_count, non_null(:integer) do
    #   resolve(fn goal, _args, _resolution ->
    #     {:ok, Enum.count(goal.conversions)}
    #   end)
    # end

    field :path, non_null(list_of(non_null(:path_goal_step)))
    # field :path, non_null(list_of(non_null(:path_goal_step))) do
    #   resolve(fn goal, _args, _resolution ->
    #     {:ok,
    #      Enum.map(goal.path, fn step ->
    #        %{
    #          url: step.url,
    #          match_type: step.match_type,
    #          index: step.index
    #        }
    #      end)}
    #   end)
    # end

    interface(:goal_entity)
  end

  object :path_goal_step do
    field(:url, non_null(:string))
    field(:match_type, non_null(:page_matcher_match_type))
    field(:index, non_null(:integer))
  end
end
