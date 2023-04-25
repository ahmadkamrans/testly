defmodule Testly.Repo.Migrations.SetNotNullFields do
  use Ecto.Migration

  def change do
    alter table(:feedback_responses) do
      modify(:first_interaction_at, :utc_datetime, null: false)
    end

    alter table(:feedback_answers) do
      modify(:answered_at, :utc_datetime, null: false)
    end
  end
end
