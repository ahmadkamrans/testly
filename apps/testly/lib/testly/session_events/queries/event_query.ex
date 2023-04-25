defmodule Testly.SessionEvents.EventQuery do
  import Ecto.Query

  alias Testly.SessionEvents.EventSchema

  def from_event do
    from(e in EventSchema, as: :event)
  end

  def where_session_recording_id(query, id) do
    where(query, [event: e], e.session_recording_id == ^id)
  end

  def where_page_id(query, id) do
    where(query, [event: e], e.page_id == ^id)
  end

  def where_processed(query) do
    where(query, [event: e], e.is_processed == true)
  end

  def where_not_processed(query) do
    where(query, [event: e], e.is_processed == false)
  end

  def order_by_happened_at_asc(query) do
    order_by(query, [event: e], asc: e.happened_at)
  end

  def select_raw_map(query) do
    select(query, [event: e], map(e, [:data, :type, :happened_at]))
  end
end
