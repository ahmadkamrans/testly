defmodule Testly.Feedback.QuestionSchema do
  use Testly.Schema

  alias Testly.Feedback.{Poll}

  @type t :: %__MODULE__{}

  schema "feedback_questions" do
    belongs_to :poll, Poll
    field :type, Testly.FeedbackQuestionType
    field :title, :string
    field :index, :integer
    field :data, :map
  end

  @spec changeset(QuestionSchema.t(), Question.t()) :: Changeset.t()
  def changeset(schema, question) do
    params = Map.from_struct(question)

    schema
    |> cast(params, [:id, :poll_id, :type, :title, :index, :data])
  end
end
