defmodule Testly.SplitTests.VariationVisit do
  use Testly.Schema

  alias Testly.SplitTests.Variation

  # NOTE: it will exist even if session recording will be removed,
  # so split test report could be generated even without session recording to be present
  schema "split_test_variation_visits" do
    belongs_to(:variation, Variation, foreign_key: :split_test_variation_id)

    field(:session_recording_id, Ecto.UUID)
    field(:visited_at, :utc_datetime)
  end
end
