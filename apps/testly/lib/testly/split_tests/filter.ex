defmodule Testly.SplitTests.Filter do
  @moduledoc """
  Example of predicates https://github.com/activerecord-hackery/ransack#search-matchers
  """

  import Ecto.Query, only: [from: 2]

  alias __MODULE__
  alias Testly.SplitTests.SplitTest
  alias Testly.FilterApplier

  defstruct [
    :name_cont,
    :created_at_gteq,
    :created_at_lteq,
    :status_in,
    :page_type_id_in,
    :page_category_id_in
  ]

  def filter(%Filter{} = filter) do
    query = from(s_t in SplitTest, as: :split_test)

    FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:name_cont, q, value) do
    like_term = "%#{value}%"

    from([split_test: s_t] in q, where: ilike(s_t.name, ^like_term))
  end

  defp query_filter(:created_at_gteq, q, value) do
    from([split_test: s_t] in q, where: s_t.created_at >= ^value)
  end

  defp query_filter(:created_at_lteq, q, value) do
    from([split_test: s_t] in q, where: s_t.created_at <= ^value)
  end

  defp query_filter(:status_in, q, values) do
    from([split_test: s_t] in q, where: s_t.status in ^values)
  end

  defp query_filter(:page_type_id_in, q, values) do
    from([split_test: s_t] in q, where: s_t.page_type_id in ^values)
  end

  defp query_filter(:page_category_id_in, q, values) do
    from([split_test: s_t] in q, where: s_t.page_category_id in ^values)
  end
end
