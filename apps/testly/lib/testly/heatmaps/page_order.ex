defmodule Testly.Heatmaps.PageOrder do
  alias Testly.Heatmaps.{PageQuery}

  defstruct direction: :desc, field: :total_views_count

  def order(query, %__MODULE__{direction: direction, field: field}) do
    ordering(query, direction, field)
  end

  defp ordering(query, direction, :created_at) do
    PageQuery.order_by_field(query, direction, :created_at)
  end

  defp ordering(query, direction, :total_views_count) do
    PageQuery.order_by_total_views_count(query, direction)
  end
end
