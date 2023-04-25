defmodule Testly.Goals.Conversion do
  use Testly.Schema

  schema "goal_conversions" do
    belongs_to :goal, Goal
    field :session_recording_id, Ecto.UUID
    field :happened_at, :utc_datetime_usec
  end
end
