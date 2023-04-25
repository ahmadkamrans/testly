defmodule TestlyAPI.Schema.SessionRecording.EventType do
  use Absinthe.Schema.Notation

  # Testly.SessionEvents.EventTypeEnum.__enum_map__()
  enum(:session_recording_event_type,
    values: [
      :mouse_clicked,
      :mouse_moved,
      :scrolled,
      :page_visited,
      :dom_mutated,
      :window_resized,
      :css_rule_inserted,
      :css_rule_deleted
    ]
  )

  object :session_recording_event do
    field :happened_at, non_null(:datetime)
    field :type, non_null(:session_recording_event_type)

    field :data, non_null(:json)
  end
end
