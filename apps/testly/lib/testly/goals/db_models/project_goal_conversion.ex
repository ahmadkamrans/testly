defmodule Testly.Goals.ProjectGoalConversion do
  use Testly.Schema

  alias Testly.Goals.ProjectGoal

  schema "project_goal_conversions" do
    belongs_to :project_goal, ProjectGoal
    field :session_recording_id, Ecto.UUID
    field :happened_at, :utc_datetime_usec
  end
end
