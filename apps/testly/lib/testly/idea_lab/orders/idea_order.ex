require EctoEnum

EctoEnum.defenum(Testly.IdeaLab.IdeaOrderField, :idea_order_field, [
  :title,
  :category_name,
  :impact_rate
])

defmodule Testly.IdeaLab.IdeaOrder do
  use Testly.Schema
  alias Testly.OrderDirection
  alias Testly.IdeaLab.{IdeaQuery, IdeaOrderField}

  @primary_key false
  embedded_schema do
    field :direction, OrderDirection, default: :asc
    field :field, IdeaOrderField, default: :title
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:direction, :field])
  end

  def query(query, %{direction: direction, field: field}) do
    IdeaQuery.order_by_field(query, direction, field)
  end
end
