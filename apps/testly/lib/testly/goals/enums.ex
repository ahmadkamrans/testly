import EctoEnum

defenum(Testly.Goals.GoalTypeEnum, :goal_type_enum, [
  :path
])

defenum(Testly.Goals.MatchTypeEnum, :match_type_enum, [
  :matches_exactly,
  :contains,
  :begins_with,
  :ends_with
])
