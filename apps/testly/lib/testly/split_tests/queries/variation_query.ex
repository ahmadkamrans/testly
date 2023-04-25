defmodule Testly.SplitTests.VariationQuery do
  import Ecto.Query

  alias Testly.SplitTests.{Variation}

  def from_variation do
    from(v in Variation, as: :variation)
  end

  def order_by_index(query) do
    order_by(query, [variation: v], asc: :index)
  end

  def where_split_test_id(query, id) do
    where(query, [variation: v], v.split_test_id == ^id)
  end
end
