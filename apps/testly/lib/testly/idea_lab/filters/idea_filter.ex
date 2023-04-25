defmodule Testly.IdeaLab.IdeaFilter do
  use Testly.Schema
  alias Testly.IdeaLab.{IdeaQuery}

  @type t() :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :category_id_eq, :string
    field :title_cont, :string
    field :description_cont, :string
    field :impact_rate_eq, :integer
    field :like_user_id_eq, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:category_id_eq, :title_cont, :description_cont, :impact_rate_eq, :like_user_id_eq])
  end

  def query(query, filter) do
    Testly.FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:title_cont, query, value) do
    IdeaQuery.where_title_cont(query, value)
  end

  defp query_filter(:description_cont, query, value) do
    IdeaQuery.where_description_cont(query, value)
  end

  defp query_filter(:category_id_eq, query, value) do
    IdeaQuery.where_category_id(query, value)
  end

  defp query_filter(:impact_rate_eq, query, value) do
    IdeaQuery.where_impact_rate(query, value)
  end

  defp query_filter(:like_user_id_eq, query, value) do
    IdeaQuery.where_likes_user_id(query, value)
  end
end
