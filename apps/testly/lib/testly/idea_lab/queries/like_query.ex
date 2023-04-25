defmodule Testly.IdeaLab.LikeQuery do
  import Ecto.Query

  alias Testly.IdeaLab.{Like}

  def from_like do
    from(l in Like, as: :like)
  end

  def where_idea_id(query, value) do
    where(query, [like: l], l.idea_id == ^value)
  end

  def where_user_id(query, value) do
    where(query, [like: l], l.user_id == ^value)
  end
end
