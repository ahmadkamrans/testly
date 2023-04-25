defmodule TestlyAPI.Schema.SplitTest.FinishConditionTypes do
  use Absinthe.Schema.Notation

  alias Testly.SplitTests.{VisitsFinishCondition, DaysPassedFinishCondition, GoalConversionsFinishCondition, SplitTest}

  enum(:split_test_finish_condition_type,
    values: [
      :goal_conversions,
      :visits,
      :days_passed
    ]
  )

  # object :split_test_finish_condition do
  #   field :goal_conversions_count, :integer
  #   field :goal_conversions_goal_id, :uuid4
  #   field :visitors_count, :integer
  #   field :days_passed_count, :integer
  # end

  union :split_test_finish_condition do
    types([
      :split_test_goal_conversions_finish_condition,
      :split_test_visits_finish_condition,
      :split_test_days_passed_finish_condition
    ])

    resolve_type(fn
      %VisitsFinishCondition{}, _ -> :split_test_visits_finish_condition
      %DaysPassedFinishCondition{}, _ -> :split_test_days_passed_finish_condition
      %GoalConversionsFinishCondition{}, _ -> :split_test_goal_conversions_finish_condition
    end)
  end

  object :split_test_goal_conversions_finish_condition do
    field(:count, non_null(:integer))

    field(:goal, non_null(:goal)) do
      resolve(fn %GoalConversionsFinishCondition{goal_id: goal_id}, _args, _res ->
        {:ok, Testly.Goals.get_goal(%SplitTest{}, goal_id)}
      end)
    end
  end

  object :split_test_visits_finish_condition do
    field(:count, non_null(:integer))
  end

  object :split_test_days_passed_finish_condition do
    field(:count, non_null(:integer))
  end
end
