defmodule Testly.Feedback.PollQuery do
  import Ecto.Query

  alias Testly.Feedback.{Poll, QuestionQuery}

  def from_poll do
    from(p in Poll, as: :poll)
  end

  def preload_assocs(query) do
    question_query =
      QuestionQuery.from_question()
      |> QuestionQuery.order_by_index()

    preload(query,
      question_schemas: ^question_query,
      responses: [:answers]
    )
  end

  def join_responses(query) do
    join(query, :inner, [poll: p], r in assoc(p, :responses), as: :responses)
  end

  def where_project_id(query, value) do
    where(query, [poll: p], p.project_id == ^value)
  end

  def where_active(query) do
    where(query, [poll: p], p.is_active == true)
  end

  def where_name_contains(query, value) do
    where(query, [poll: p], ilike(p.name, ^"%#{value}%"))
  end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end
end
