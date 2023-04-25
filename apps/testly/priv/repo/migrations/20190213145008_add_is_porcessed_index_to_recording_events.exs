defmodule Testly.Repo.Migrations.AddIsPorcessedIndexToRecordingEvents do
  use Ecto.Migration

  def change do
    create(index(:session_recording_events, [:is_processed]))
    create(index(:session_recording_events, [:page_id]))

    create(index(:heatmap_views, [:snapshot_id]))
    create(index(:heatmap_snapshots, [:device_type]))
  end
end
