defmodule Testly.Feedback.PollFilter do
  @moduledoc """
  Example of predicates https://github.com/activerecord-hackery/ransack#search-matchers
  """
  alias Testly.Feedback.{PollQuery}

  defstruct [
    :name_cont
  ]

  @type t() :: %__MODULE__{}

  def filter(query, filter) do
    Testly.FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:name_cont, query, value) do
    PollQuery.where_name_contains(query, value)
  end
end
