defmodule Testly.SplitTests.Variation do
  use Testly.Schema

  alias Testly.SplitTests.{SplitTest, VariationVisit}
  alias __MODULE__

  import Ecto.Query

  schema "split_test_variations" do
    belongs_to :split_test, SplitTest
    has_many :visits, VariationVisit, foreign_key: :split_test_variation_id
    # has_many :conversions, Conversion, through: :visits
    field :name, :string
    field :url, :string
    field :control, :boolean, default: false
    field :index, :integer
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:url, :name, :control])
    |> validate_required([:url, :name])
    |> validate_length(:url, max: 2000)
    |> validate_length(:name, max: 2000)
  end

  def from_variations do
    from(v in Variation, as: :variation)
  end

  def order_by_index(q) do
    order_by(q, [variation: v], asc: :index)
  end
end
