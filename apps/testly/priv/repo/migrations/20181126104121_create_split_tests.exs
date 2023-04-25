defmodule Testly.Repo.Migrations.CreateSplitTests do
  use Ecto.Migration

  alias Testly.SplitTests.{SplitTestStatusEnum, FinishConditionTypeEnum}
  alias Testly.SessionRecordings.{ReferrerSourceEnum, DeviceTypeEnum}
  alias Testly.Goals.{GoalTypeEnum}

  def change do
    create table(:split_test_page_categories) do
      add(:name, :string)
    end

    create(unique_index(:split_test_page_categories, [:name]))

    create table(:split_test_page_types) do
      add(:name, :string)
    end

    create(unique_index(:split_test_page_types, [:name]))

    create table(:split_tests) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:page_category_id, references(:split_test_page_categories))
      add(:page_type_id, references(:split_test_page_types))
      add(:name, :string)
      add(:description, :text)
      add(:traffic_percent, :integer)
      add(:traffic_device_types, {:array, DeviceTypeEnum.type()}, default: [], null: false)
      add(:traffic_referrer_sources, {:array, ReferrerSourceEnum.type()}, default: [], null: false)
      add(:status, SplitTestStatusEnum.type())
      timestamps()
    end

    create(index(:split_tests, [:project_id]))

    create table(:split_test_finish_conditions) do
      add(:split_test_id, references(:split_tests, on_delete: :delete_all), null: false)
      add(:type, FinishConditionTypeEnum.type())
      add(:count, :integer)
    end

    create table(:split_test_variations) do
      add(:split_test_id, references(:split_tests, on_delete: :delete_all), null: false)
      add(:name, :string)
      add(:url, :string)
      add(:index, :integer)
      add(:control, :boolean, default: false, null: false)
    end

    create table(:split_test_variation_visits) do
      add(:split_test_variation_id, references(:split_test_variations, on_delete: :delete_all), null: false)
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
    end

    create(unique_index(:split_test_variation_visits, [:split_test_variation_id, :session_recording_id]))
  end
end
