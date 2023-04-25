defmodule Testly.FilterApplier do
  @moduledoc """
  Example of predicates https://github.com/activerecord-hackery/ransack#search-matchers
  """

  def apply(query, filter, query_filter) do
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
