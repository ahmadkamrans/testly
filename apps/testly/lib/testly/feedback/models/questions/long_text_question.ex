defmodule Testly.Feedback.LongTextQuestion do
  use Testly.Feedback.Question

  question_model do
    field :type, Testly.FeedbackQuestionType, default: :long_text
  end
end
