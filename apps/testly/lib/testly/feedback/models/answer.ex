defmodule Testly.Feedback.Answer do
  use Testly.Schema

  alias Testly.Feedback.{Response}

  schema "feedback_answers" do
    belongs_to :response, Response
    field :question_id, Ecto.UUID
    field :content, :string
    field :answered_at, :utc_datetime_usec
  end

  def changeset(schema, params) do
    # TODO: Validate that question id is within poll
    schema
    |> cast(params, [:question_id, :content, :answered_at])
    |> validate_required([:question_id, :content, :answered_at])
  end
end
