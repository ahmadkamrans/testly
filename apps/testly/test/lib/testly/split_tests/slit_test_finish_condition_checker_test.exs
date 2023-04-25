# defmodule Testly.SplitTests.SplitTestFinishConditionCheckerTest do
#   use ExUnit.Case, async: true

#   alias Testly.SplitTests.DaysPassedFinishCondition
#   alias Testly.SplitTests.GoalConversionsFinishCondition
#   alias Testly.SplitTests.VisitsFinishCondition
#   alias Testly.SplitTests.SplitTest
#   alias Testly.SplitTests.SplitTestFinishConditionChecker

#   test "when days_passed condition" do
#     finish_condition = %DaysPassedFinishCondition{count: 3}

#     assert SplitTestFinishConditionChecker.check(%SplitTest{
#              created_at: Timex.now() |> Timex.shift(days: -4),
#              finish_condition: finish_condition
#            }) === true

#     assert SplitTestFinishConditionChecker.check(%SplitTest{
#              created_at: Timex.now() |> Timex.shift(days: -2),
#              finish_condition: finish_condition
#            }) === false
#   end

#   test "when goal_conversions condition" do
#     finish_condition = %GoalConversionsFinishCondition{count: 2, goal_id: "123"}

#     assert SplitTestFinishConditionChecker.check(
#              %SplitTest{
#                finish_condition: finish_condition
#              },
#              1
#            ) === false

#     assert SplitTestFinishConditionChecker.check(
#              %SplitTest{
#                finish_condition: finish_condition
#              },
#              4
#            ) === true
#   end

#   test "when visits condition" do
#     finish_condition = %VisitsFinishCondition{count: 4}

#     assert SplitTestFinishConditionChecker.check(
#              %SplitTest{
#                finish_condition: finish_condition
#              },
#              2
#            ) === false

#     assert SplitTestFinishConditionChecker.check(
#              %SplitTest{
#                finish_condition: finish_condition
#              },
#              4
#            ) === true
#   end
# end
