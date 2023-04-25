defmodule Testly.Repo.Migrations.AddTestIdeaIdToSessionRecording do
  use Ecto.Migration

  def change do
    alter table(:split_tests) do
      add(:test_idea_id, references(:test_ideas, on_delete: :nilify_all), null: true)
    end

    create(index(:split_tests, [:test_idea_id]))
  end
end
