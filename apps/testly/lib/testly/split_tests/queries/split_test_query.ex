defmodule Testly.SplitTests.SplitTestQuery do
  import Ecto.Query

  alias Testly.SplitTests.{SplitTest}

  def from_split_test do
    from(s_t in SplitTest, as: :split_test)
  end

  #   def where_visits_to(session_recording_id) do
  #     from(s_t in SplitTest, as: :split_test)
  #     |> join(:left, [split_test: s_p], v in assoc(s_p, :variations), as: :variation)
  #     |> join(:left, [variation: v], v in assoc(v, :visits), as: :variation_visit)
  #     |> where([variation_visit: v_s], v_s.session_recording_id == ^session_recording_id)
  #     |> preload([variation: v, variation_visit: v_v], variations: {v, visits: v_v})
  #   end

  def preload_assocs(query, variations_query) do
    preload(query, [], [
      :goals,
      :page_category,
      :page_type,
      :finish_condition,
      variations: ^variations_query
    ])
  end

  def where_name_cont(query, value) do
    from([split_test: s_t] in query, where: ilike(s_t.name, ^"%#{value}%"))
  end

  def where_created_at_gteq(query, value) do
    from([split_test: s_t] in query, where: s_t.created_at >= ^value)
  end

  def where_created_at_gteq(query, value) do
    from([split_test: s_t] in query, where: s_t.created_at <= ^value)
  end

  def where_project_id(query, project_id) do
    where(query, [split_test: s_t], s_t.project_id == ^project_id)
  end

  def where_page_type_id_in(query, values) do
    from([split_test: s_t] in query, where: s_t.page_type_id in ^values)
  end

  def where_page_category_id_in(query, values) do
    from([split_test: s_t] in query, where: s_t.page_category_id in ^values)
  end

  def where_status_in(query, values) do
    from([split_test: s_t] in query, where: s_t.status in ^values)
  end

  def where_status_active(query) do
    where(query, [split_test: s_t], s_t.status == "active")
  end

  def order_by_created_at(query) do
    order_by(query, desc: :created_at)
  end

  def distinct(query) do
    distinct(query, true)
  end
end
