defmodule Testly.SplitTests.VariationVisit do
  use Testly.Schema

  alias Testly.SplitTests.Variation
  alias Testly.SplitTests.SessionRecording

  schema "split_test_variation_visits" do
    belongs_to :variation, Variation, foreign_key: :split_test_variation_id
    belongs_to :session_recording, SessionRecording
  end
end
