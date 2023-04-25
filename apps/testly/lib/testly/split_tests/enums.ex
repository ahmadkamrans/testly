import EctoEnum

defenum(Testly.SplitTests.SplitTestStatusEnum, :split_test_status, [
  :draft,
  :active,
  :paused,
  :finished
])

defenum(Testly.SplitTests.FinishConditionTypeEnum, :finish_condition_type, [
  :visits,
  :days_passed,
  :goal_conversions
])
