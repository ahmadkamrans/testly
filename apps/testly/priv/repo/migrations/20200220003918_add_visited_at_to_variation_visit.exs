defmodule Testly.Repo.Migrations.AddVisitedAtToVariationVisit do
  use Ecto.Migration

  def up do
    alter table(:split_test_variation_visits) do
      add(:visited_at, :utc_datetime)
    end

    execute("""
    UPDATE
      split_test_variation_visits AS v_v
    SET
      visited_at = s_r.created_at
    FROM
      session_recordings AS s_r
    WHERE
      s_r.id = v_v.session_recording_id
    """)

    execute("""
    DELETE FROM
      split_test_variation_visits
    WHERE
      split_test_variation_visits.visited_at IS NULL
    """)

    alter table(:split_test_variation_visits) do
      modify(:visited_at, :utc_datetime, null: false)
    end
  end

  def down do
    alter table(:split_test_variation_visits) do
      remove(:visited_at)
    end
  end
end
