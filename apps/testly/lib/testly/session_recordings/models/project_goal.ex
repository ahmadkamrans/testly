defmodule Testly.SessionRecordings.ProjectGoal do
  use Testly.Schema

  alias __MODULE__

  @type t :: %ProjectGoal{
          id: Testly.Schema.pk(),
          name: String.t()
        }

  schema "project_goals" do
    # many_to_many :session_recordings, SessionRecording, join_through: "goals_session_recordings"
    # belongs_to :project, Project
    field :name, :string
  end
end
