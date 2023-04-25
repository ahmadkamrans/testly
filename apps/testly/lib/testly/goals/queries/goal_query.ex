defmodule Testly.Goals.GoalQuery do
  import Ecto.Query

  alias Testly.Goals.{Goal}

  def from_goal do
    from(g in Goal, as: :goal)
  end

  def where_project_id(query, project_id) do
    where(query, [goal: g], g.project_id == ^project_id)
  end

  def order_by_created_at_desc(query) do
    order_by(query, [goal: g], desc: g.created_at)
  end

  def preload_assocs(query) do
    preload(query, [], [:conversions])
  end
end
