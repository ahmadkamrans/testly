defmodule Testly.Feedback.LongTextQuestion do
  use Testly.Feedback.Question

  @type t :: %__MODULE__{}

  question_model do
    field :type, Testly.FeedbackQuestionType, default: :long_text
  end
end
