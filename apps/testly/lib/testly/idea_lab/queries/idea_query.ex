defmodule Testly.IdeaLab.IdeaQuery do
  import Ecto.Query

  alias Testly.IdeaLab.{Idea, Like}

  def from_idea do
    from(i in Idea, as: :idea)
  end

  def preload_assocs(query) do
    preload(query, [:category])
  end

  def join_category(query) do
    join(query, :left, [idea: i], c in assoc(i, :category), as: :category)
  end

  def order_by_field(query, direction, :category_name) do
    order_by(query, [category: c], {^direction, c.name})
  end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end

  def where_category_id(query, value) do
    where(query, [idea: i], i.category_id == ^value)
  end

  def where_impact_rate(query, value) do
    where(query, [idea: i], i.impact_rate == ^value)
  end

  def where_likes_user_id(query, value) do
    like_query = from(l in Like, where: l.user_id == ^value, select: l)

    from(
      i in query,
      join: l in subquery(like_query),
      on: l.idea_id == i.id
    )
  end

  def where_title_cont(query, value) do
    where(query, [idea: i], ilike(i.title, ^"%#{value}%"))
  end

  def where_description_cont(query, value) do
    where(query, [idea: i], ilike(i.description, ^"%#{value}%"))
  end
end
