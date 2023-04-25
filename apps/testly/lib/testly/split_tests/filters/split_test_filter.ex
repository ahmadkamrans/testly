defmodule Testly.SplitTests.SplitTestFilter do
  use Testly.Schema
  alias Testly.FilterApplier
  alias Testly.SplitTests.{SplitTestQuery}

  @type t() :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :name_cont, :string
    field :created_at_gteq, :utc_datetime
    field :created_at_lteq, :utc_datetime
    field :status_in, :string
    field :page_type_id_in, :string
    field :page_category_id_in, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [
      :name_cont,
      :created_at_gteq,
      :created_at_lteq,
      :status_in,
      :page_type_id_in,
      :page_category_id_in
    ])
  end

  def cast_params(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, [
      :name_cont,
      :created_at_gteq,
      :created_at_lteq,
      :status_in,
      :page_type_id_in,
      :page_category_id_in
    ])
    |> apply_changes
  end

  def query(query, filter) do
    Testly.FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:name_cont, query, value) do
    SplitTestQuery.where_name_cont(query, value)
  end

  defp query_filter(:created_at_gteq, query, value) do
    SplitTestQuery.where_created_at_gteq(query, value)
  end

  defp query_filter(:created_at_lteq, query, value) do
    SplitTestQuery.where_created_at_lteq(query, value)
  end

  defp query_filter(:status_in, query, values) do
    SplitTestQuery.where_status_in(query, values)
  end

  defp query_filter(:page_type_id_in, query, values) do
    SplitTestQuery.where_page_type_id_in(query, values)
  end

  defp query_filter(:page_category_id_in, query, values) do
    SplitTestQuery.where_page_category_id_in(query, values)
  end
end
