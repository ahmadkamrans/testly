defmodule Testly.Repo.Migrations.GoalConversionFk do
  use Ecto.Migration

  def up do
    drop(constraint(:project_goal_conversions, "project_goal_conversions_session_recording_id_fkey"))

    alter table(:project_goal_conversions) do
      modify(:session_recording_id, references(:session_recordings, on_delete: :nilify_all), null: true)
    end
  end

  def down do
    drop(constraint(:project_goal_conversions, "project_goal_conversions_session_recording_id_fkey"))

    alter table(:project_goal_conversions) do
      modify(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
    end
  end
end
