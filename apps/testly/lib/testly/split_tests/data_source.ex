defmodule Testly.SplitTests.DataSource do
  alias Testly.{
    Pagination
  }

  alias Testly.SplitTests.{
    SplitTestQuery,
    SplitTest,
    SplitTestFilter
  }

  def query(SplitTest, %{filter: filter_params, pagination: pagination_params}) do
    filter = SplitTestFilter.cast_params(filter_params)
    pagination = Pagination.cast_params(pagination_params)

    SplitTestQuery.from_split_test()
    |> Pagination.query(pagination)
    |> SplitTestFilter.query(filter)
  end

  def query(queryable, _params) do
    queryable
  end
end
