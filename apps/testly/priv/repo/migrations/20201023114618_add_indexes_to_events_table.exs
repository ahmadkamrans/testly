defmodule Testly.Repo.Migrations.AddIndexesToEventsTable do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create index(
      "session_recording_events", ["happened_at ASC NULLS LAST"],
      where: "is_processed = false",
      name: "happened_at_not_processed_select_index",
      concurrently: true
    )

    create index(
      "session_recording_events", [:session_recording_id],
      where: "is_processed = false",
      name: "recording_id_not_processed_select_index",
      concurrently: true
    )
  end
end
