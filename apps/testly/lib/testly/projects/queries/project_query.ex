defmodule Testly.Projects.ProjectQuery do
  import Ecto.Query

  alias Testly.Projects.{Project}

  def from_project do
    from(p in Project, as: :project)
  end

  # def preload_assocs(query) do
  #   preload(query, [:category])
  # end

  # def join_category(query) do
  #   join(query, :left, [idea: i], c in assoc(i, :category), as: :category)
  # end

  # def order_by_field(query, direction, :category_name) do
  #   order_by(query, [category: c], {^direction, c.name})
  # end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end

  # def where_category_id(query, value) do
  #   where(query, [idea: i], i.category_id == ^value)
  # end

  # def where_impact_rate(query, value) do
  #   where(query, [idea: i], i.impact_rate == ^value)
  # end

  def where_domain_cont(query, value) do
    where(query, [project: p], ilike(p.domain, ^"%#{value}%"))
  end

  # def where_description_cont(query, value) do
  #   where(query, [idea: i], ilike(i.description, ^"%#{value}%"))
  # end
end
