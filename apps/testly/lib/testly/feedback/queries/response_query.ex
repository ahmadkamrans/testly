defmodule Testly.Feedback.ResponseQuery do
  import Ecto.Query

  alias Testly.Feedback.Response

  def preload_assocs(query) do
    preload(query, [:answers])
  end

  def from_response do
    from(r in Response, as: :response)
  end

  def where_poll_id(query, value) do
    where(query, [response: r], r.poll_id == ^value)
  end

  def where_session_recording_id(query, value) do
    where(query, [response: r], r.session_recording_id == ^value)
  end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end
end
