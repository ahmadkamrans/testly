defmodule Testly.Heatmaps.ViewQuery do
  import Ecto.Query, only: [from: 2]

  alias Testly.Heatmaps.View

  def from_views do
    from(v in View, as: :view)
  end

  # def join_view(query) do
  #   from([snapshot: s] in query, join: v in assoc(s, :views), as: :view)
  # end

  def happened_at_less_than(query, date) do
    from([view: v] in query, where: v.happened_at <= ^date)
  end

  def happened_at_greater_than(query, date) do
    from([view: v] in query, where: v.happened_at >= ^date)
  end
end
