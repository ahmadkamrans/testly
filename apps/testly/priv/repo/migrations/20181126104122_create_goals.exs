defmodule Testly.Repo.Migrations.CreateGoals do
  use Ecto.Migration

  alias Testly.Goals.GoalTypeEnum

  def change do
    create table(:goals) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:name, :string)
      add(:value, :decimal)
      add(:type, GoalTypeEnum.type(), null: false)
      add(:path, {:array, :map})
      timestamps()
    end

    create(index(:goals, [:project_id]))

    create table(:goal_conversions) do
      add(:goal_id, references(:goals, on_delete: :delete_all), null: false)
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      # add(:page_id, references(:session_recording_pages, on_delete: :delete_all), null: false)
      add(:happened_at, :utc_datetime_usec)
    end

    create(unique_index(:goal_conversions, [:goal_id, :session_recording_id, :happened_at]))

    create table(:split_tests_goals) do
      add(:goal_id, references(:goals, on_delete: :delete_all), null: false)
      add(:split_test_id, references(:split_tests, on_delete: :delete_all), null: false)
    end

    # TODO: Maybe we need it
    # create table(:split_tests_goals_conversions) do
    #   # id
    #   # session_recording_id
    #   # happened_at
    # end

    alter table(:split_test_finish_conditions) do
      add(:goal_id, references(:goals, on_delete: :delete_all))
    end
  end
end
