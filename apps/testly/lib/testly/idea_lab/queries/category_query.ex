defmodule Testly.IdeaLab.CategoryQuery do
  import Ecto.Query

  alias Testly.IdeaLab.{Category}

  def from_category do
    from(c in Category, as: :category)
  end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end
end
