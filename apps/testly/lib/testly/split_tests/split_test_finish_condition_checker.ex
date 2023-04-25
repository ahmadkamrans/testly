defmodule Testly.SplitTests.SplitTestFinishConditionChecker do
  alias Testly.Goals
  alias Testly.SplitTests.{FinishCondition, SplitTest}

  def check(%SplitTest{finish_condition: %FinishCondition{type: :days_passed, count: count}, created_at: created_at}) do
    Timex.diff(DateTime.utc_now(), created_at, :days) >= count
  end

  def check(%SplitTest{finish_condition: %FinishCondition{type: :goal_conversions, count: count}}) do
    # Goals.get_split_test_goal_conversions_count(goal_id)
    0 >= count
  end

  def check(%SplitTest{finish_condition: %FinishCondition{type: :visits, count: count}}) do
    # get_visits_count(split_test)
    0 >= count
  end
end
