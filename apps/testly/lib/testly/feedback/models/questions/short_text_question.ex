defmodule Testly.Feedback.ShortTextQuestion do
  use Testly.Feedback.Question

  @type t :: %__MODULE__{}

  question_model do
    field :type, Testly.FeedbackQuestionType, default: :short_text
  end
end
