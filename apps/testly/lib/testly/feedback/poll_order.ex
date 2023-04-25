defmodule Testly.Feedback.PollOrder do
  alias Testly.Feedback.{PollQuery}

  defstruct direction: :desc, field: :created_at

  def order(query, %__MODULE__{direction: direction, field: field}) do
    ordering(query, direction, field)
  end

  defp ordering(query, direction, :created_at) do
    PollQuery.order_by_field(query, direction, :created_at)
  end

  defp ordering(query, direction, :name) do
    PollQuery.order_by_field(query, direction, :name)
  end

end
