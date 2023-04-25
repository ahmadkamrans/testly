defmodule Testly.SplitTests.SplitTestFinishConditionChecker do
  alias Testly.SplitTests.{DaysPassedFinishCondition, GoalConversionsFinishCondition, VisitsFinishCondition, SplitTest}

  def check(%SplitTest{finish_condition: %DaysPassedFinishCondition{count: count}, created_at: created_at}) do
    Timex.diff(DateTime.utc_now(), created_at, :days) >= count
  end

  def check(
        %SplitTest{finish_condition: %GoalConversionsFinishCondition{count: count}},
        conversions_count
      ) do
    conversions_count >= count
  end

  def check(%SplitTest{finish_condition: %VisitsFinishCondition{count: count}}, visits_count) do
    visits_count >= count
  end
end
