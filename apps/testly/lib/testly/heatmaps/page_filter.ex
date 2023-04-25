defmodule Testly.Heatmaps.PageFilter do
  @moduledoc """
  Example of predicates https://github.com/activerecord-hackery/ransack#search-matchers
  """
  alias Testly.Heatmaps.{PageQuery}

  defstruct [
    :url_cont
  ]

  @type t() :: %__MODULE__{}

  def filter(query, filter) do
    run(query, filter, &query_filter/3)
  end

  defp query_filter(:url_cont, query, value) do
    PageQuery.where_url_contains(query, value)
  end

  defp run(query, filter, query_filter) do
    normalized_filters =
      for {name, value} <- Map.from_struct(filter), value != nil, value != "" do
        {name,
         if String.ends_with?(to_string(name), "_in") do
           for data <- value, data != nil, data != "", do: data
         else
           value
         end}
      end

    Enum.reduce(normalized_filters, query, fn {filter_name, value}, q ->
      query_filter.(filter_name, q, value)
    end)
  end
end
