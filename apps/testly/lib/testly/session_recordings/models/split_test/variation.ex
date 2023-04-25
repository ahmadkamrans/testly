defmodule Testly.SessionRecordings.SplitTest.Variation do
  use Testly.Schema

  schema "split_test_variations" do
    field :split_test_id, Ecto.UUID
    field :name, :string
    field :url, :string
    field :control, :boolean, default: false
  end
end
