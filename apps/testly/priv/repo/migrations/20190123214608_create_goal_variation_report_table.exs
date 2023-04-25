defmodule Testly.Repo.Migrations.CreateGoalVariationReportTable do
  use Ecto.Migration

  def change do
    create table(:split_test_goal_variation_reports) do
      add(:goal_id, references(:split_test_goals, on_delete: :delete_all), null: false)
      add(:variation_id, references(:split_test_variations, on_delete: :delete_all), null: false)

      add(:conversions_count, :integer)
      add(:visits_count, :integer)
      add(:conversion_rate, :float)
      add(:revenue, :decimal)
      add(:improvement_rate, :float)
      add(:control, :boolean)
      add(:date, :utc_datetime)

      add(:rates_by_date, :jsonb)
      timestamps()
    end

    create(index(:split_test_goal_variation_reports, [:goal_id]))
    create(index(:split_test_goal_variation_reports, [:variation_id]))
    create(unique_index(:split_test_goal_variation_reports, [:goal_id, :variation_id]))
  end
end
