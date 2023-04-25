defmodule Testly.Feedback.Response do
  use Testly.Schema

  alias Testly.Feedback.{Poll, Answer}

  schema "feedback_responses" do
    belongs_to :poll, Poll
    field :session_recording_id, Ecto.UUID
    field :page_url, :string
    field :first_interaction_at, :utc_datetime_usec
    has_many :answers, Answer
    timestamps()
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:page_url, :session_recording_id, :first_interaction_at])
    |> validate_required([:page_url, :session_recording_id, :first_interaction_at])
    |> cast_assoc(:answers)
  end
end
