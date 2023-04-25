defmodule Testly.SessionRecordings.SplitTest.VariationVisit do
  use Testly.Schema

  alias Testly.SessionRecordings.SplitTest.{Variation, GoalConversion}
  alias Testly.SessionRecordings.SessionRecording

  schema "split_test_variation_visits" do
    belongs_to :variation, Variation, foreign_key: :split_test_variation_id
    belongs_to :session_recording, SessionRecording

    has_many :goal_conversions, GoalConversion, foreign_key: :split_test_variation_visit_id

    field :visited_at, :utc_datetime
  end
end
