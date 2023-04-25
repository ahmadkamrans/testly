defmodule Testly.Repo.Migrations.CreateHeatmaps do
  use Ecto.Migration

  alias Testly.SessionRecordings.{DeviceTypeEnum}

  def change do
    create table(:heatmap_pages) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:url, :string, null: false)
      timestamps()
    end

    create(unique_index(:heatmap_pages, [:project_id, :url]))

    create table(:heatmap_snapshots) do
      add(:page_id, references(:heatmap_pages, on_delete: :delete_all), null: false)
      add(:device_type, DeviceTypeEnum.type())
      add(:doc_type, :string)
      add(:dom_nodes, :map)
    end

    create(unique_index(:heatmap_snapshots, [:page_id, :device_type]))

    create table(:heatmap_views) do
      add(:snapshot_id, references(:heatmap_snapshots, on_delete: :delete_all), null: false)
      add(:session_recording_page_id, references(:session_recording_pages, on_delete: :nilify_all))
      add(:visited_at, :utc_datetime_usec)
      add(:elements, {:array, :map})
    end

    create(unique_index(:heatmap_views, [:session_recording_page_id]))
  end
end
