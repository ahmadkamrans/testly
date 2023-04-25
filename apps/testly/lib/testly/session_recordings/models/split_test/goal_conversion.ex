defmodule Testly.SessionRecordings.SplitTest.GoalConversion do
  use Testly.Schema

  alias Testly.SessionRecordings.SplitTest.{Goal, VariationVisit}
  alias __MODULE__

  @type t :: %GoalConversion{
          id: Testly.Schema.pk()
        }

  schema "split_test_goal_conversions" do
    belongs_to :goal, Goal, foreign_key: :split_test_goal_id
    belongs_to :variation_visit, VariationVisit, foreign_key: :split_test_variation_visit_id

    field :happened_at, :utc_datetime_usec
  end
end
