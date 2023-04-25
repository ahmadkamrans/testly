defmodule Testly.Feedback.QuestionQuery do
  import Ecto.Query

  alias Testly.Feedback.QuestionSchema

  def from_question do
    from(q in QuestionSchema, as: :question)
  end

  def order_by_index(query) do
    order_by(query, [question: question], [asc: question.index])
  end
end
