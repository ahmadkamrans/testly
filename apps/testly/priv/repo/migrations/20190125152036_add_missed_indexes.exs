defmodule Testly.Repo.Migrations.AddMissedIndexes do
  use Ecto.Migration

  def change do
    create(index(:split_test_variation_visits, [:session_recording_id]))
    create(index(:split_test_goal_conversions, [:split_test_variation_visit_id]))
    create(index(:project_goal_conversions, [:session_recording_id]))
  end
end
