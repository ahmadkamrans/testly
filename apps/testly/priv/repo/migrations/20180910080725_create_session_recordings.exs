defmodule Testly.Repo.Migrations.CreateSessionRecordings do
  use Ecto.Migration

  alias Testly.SessionRecordings.{ReferrerSourceEnum, DeviceTypeEnum}
  alias Testly.SessionEvents.{EventTypeEnum}

  def change do
    create table(:session_recordings) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:duration, :integer, null: false, default: 0)
      add(:clicks_count, :integer, null: false, default: 0)
      add(:referrer, :text)
      add(:referrer_source, ReferrerSourceEnum.type())
      add(:is_ready, :boolean, null: false, default: false)
      timestamps()
    end
    create index(:session_recordings, [:project_id])
    create index(:session_recordings, [:created_at])
    create index(:session_recordings, [:duration])
    create index(:session_recordings, [:referrer_source])

    create table(:session_recording_locations) do
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      add(:ip, :string)
      add(:country, :string)
      add(:country_iso_code, :string)
      add(:city, :string)
      add(:latitude, :float)
      add(:longitude, :float)
    end
    create index(:session_recording_locations, [:country_iso_code])
    create index(:session_recording_locations, [:session_recording_id])

    create table(:session_recording_devices) do
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      add(:type, DeviceTypeEnum.type())
      add(:user_agent, :text)
      add(:browser_name, :string)
      add(:browser_version, :string)
      add(:os_name, :string)
      add(:os_version, :string)
      add(:screen_height, :integer)
      add(:screen_width, :integer)
    end
    create index(:session_recording_devices, [:session_recording_id])
    create index(:session_recording_devices, [:type])

    create table(:session_recording_pages) do
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      add(:url, :text)
      add(:title, :text)
      add(:duration, :integer, null: false, default: 0)
      add(:clicks_count, :integer, null: false, default: 0)
      add(:visited_at, :utc_datetime_usec)
    end
    create(index(:session_recording_pages, [:session_recording_id]))
    create(unique_index(:session_recording_pages, [:session_recording_id, :visited_at]))

    create table(:session_recording_events) do
      add(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
      add(:page_id, references(:session_recording_pages, on_delete: :delete_all))
      add(:is_processed, :boolean, null: false, default: false)
      add(:happened_at, :utc_datetime_usec, null: false)
      add(:type, EventTypeEnum.type(), null: false)
      add(:data, :map, null: false)
    end
    create(index(:session_recording_events, [:session_recording_id]))
    create(unique_index(:session_recording_events, [:session_recording_id, :happened_at, :type]))
  end
end
