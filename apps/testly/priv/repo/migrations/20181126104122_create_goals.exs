defmodule Testly.Repo.Migrations.CreateGoals do
  use Ecto.Migration

  alias Testly.Goals.GoalTypeEnum

  def change do
    create table(:project_goals) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:name, :string)
      add(:value, :decimal)
      add(:type, GoalTypeEnum.type(), null: false)
      add(:path, {:array, :map})
      timestamps()
    end

    create(index(:project_goals, [:project_id]))

    create table(:split_test_goals) do
      add(:split_test_id, references(:split_tests, on_delete: :delete_all), null: false)
      add(:name, :string)
      add(:value, :decimal)
      add(:index, :integer)
      add(:type, GoalTypeEnum.type(), null: false)
      add(:path, {:array, :map})
      timestamps()
    end

    create(index(:split_test_goals, [:split_test_id]))

    create table(:split_test_goal_conversions) do
      add(:split_test_goal_id, references(:split_test_goals, on_delete: :delete_all), null: false)
      add(:split_test_variation_visit_id, references(:split_test_variation_visits, on_delete: :delete_all), null: false)
      add(:happened_at, :utc_datetime_usec)
    end

    create(unique_index(:split_test_goal_conversions, [:split_test_goal_id, :split_test_variation_visit_id]))

    create table(:project_goal_conversions) do
      add(:project_goal_id, references(:project_goals, on_delete: :delete_all), null: false)
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      add(:happened_at, :utc_datetime_usec)
    end

    create(unique_index(:project_goal_conversions, [:project_goal_id, :session_recording_id]))

    alter table(:split_test_finish_conditions) do
      # add(:goal_conversions_goal_id, references(:split_test_goals, on_delete: :delete_all))
      add(:goal_id, references(:split_test_goals, on_delete: :delete_all))
    end
  end
end
