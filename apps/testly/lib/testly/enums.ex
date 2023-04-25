# TODO: Move all enums here
import EctoEnum

defenum(Testly.OrderDirection, :order_direction, [
  :asc,
  :desc
])

defenum(Testly.PageMatcherType, :page_matcher_type, [
  :matches_exactly,
  :contains,
  :begins_with,
  :ends_with
])

# feedback
defenum(Testly.FeedbackQuestionType, :feedback_question_type_enum, [
  :short_text,
  :long_text,
  :email,
  :radio_button,
  :checkbox
])

defenum(Testly.PollShowOption, :feedback_poll_show_option, [
  :always,
  :hide_after_submit
])

# # session recordings
# defenum(Testly.ReferrerSourceEnum, :referrer_source_enum, [
#   :social,
#   :search,
#   :paid,
#   :email,
#   :direct,
#   :unknown
# ])

# defenum(Testly.DeviceTypeEnum, :device_type_enum, [
#   :desktop,
#   :mobile,
#   :tablet
# ])

# # session events
# defenum(Testly.EventTypeEnum, :session_recordings_event_type_enum, [
#   :mouse_clicked,
#   :mouse_moved,
#   :scrolled,
#   :page_visited,
#   :dom_mutated,
#   :url_changed,
#   :title_changed,
#   :window_resized
# ])

# # goals
# defenum(Testly.GoalTypeEnum, :goal_type_enum, [
#   :path
# ])

# defenum(Testly.MatchTypeEnum, :match_type_enum, [
#   :matches_exactly,
#   :contains,
#   :begins_with,
#   :ends_with
# ])

# # split tests
# defenum(Testly.SplitTestStatusEnum, :split_test_status, [
#   :draft,
#   :active,
#   :paused,
#   :finished
# ])

# defenum(Testly.SplitTestFinishConditionTypeEnum, :split_test_finish_condition_type, [
#   :visits,
#   :days_passed,
#   :goal_conversions
# ])
