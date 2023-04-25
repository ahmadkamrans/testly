defmodule Testly.Repo.Migrations.VariationVisitFk do
  use Ecto.Migration

  def up do
    drop(constraint(:split_test_variation_visits, "split_test_variation_visits_session_recording_id_fkey"))

    alter table(:split_test_variation_visits) do
      modify(:session_recording_id, references(:session_recordings, on_delete: :nilify_all), null: true)
    end
  end

  def down do
    drop(constraint(:split_test_variation_visits, "split_test_variation_visits_session_recording_id_fkey"))

    alter table(:split_test_variation_visits) do
      modify(:session_recording_id, references(:session_recordings, on_delete: :delete_all), null: false)
    end
  end
end
