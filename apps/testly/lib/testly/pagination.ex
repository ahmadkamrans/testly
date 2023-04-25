defmodule Testly.Pagination do
  use Testly.Schema
  import Ecto.Query

  # @pagination [page_size: 10]
  # @pagination_distance 5

  @primary_key false
  embedded_schema do
    field :page, :integer, default: 1
    field :per_page, :integer, default: 10
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:page, :per_page])
  end

  def paginate(query, pagination) do
    query
    |> limit(^pagination.per_page)
    |> offset(^((pagination.page - 1) * pagination.per_page))
  end

  def query(query, pagination) do
    query
    |> limit(^pagination.per_page)
    |> offset(^((pagination.page - 1) * pagination.per_page))
  end
end
