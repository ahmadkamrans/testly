require EctoEnum

EctoEnum.defenum(Testly.IdeaLab.CategoryOrderField, :idea_order_field, [
  :name,
  :color
])

defmodule Testly.IdeaLab.CategoryOrder do
  use Testly.Schema
  alias Testly.OrderDirection
  alias Testly.IdeaLab.{CategoryQuery, CategoryOrderField}

  @primary_key false
  embedded_schema do
    field :direction, OrderDirection, default: :asc
    field :field, CategoryOrderField, default: :name
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:direction, :field])
  end

  def query(query, %{direction: direction, field: field}) do
    CategoryQuery.order_by_field(query, direction, field)
  end
end
