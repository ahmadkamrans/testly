defmodule Testly.Repo.Migrations.AddFocusedAtToPollResponse do
  use Ecto.Migration

  def change do
    alter table(:feedback_responses) do
      add(:first_interaction_at, :utc_datetime)
    end

    alter table(:feedback_answers) do
      add(:answered_at, :utc_datetime)
    end
  end
end
