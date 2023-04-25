defmodule Testly.Repo.Migrations.CreateIdeas do
  use Ecto.Migration

  def change do
    create table(:test_idea_categories) do
      add(:name, :string)
      add(:color, :string)
      timestamps()
    end

    create table(:test_ideas) do
      add(:category_id, references(:test_idea_categories, on_delete: :delete_all), null: false)

      add(:title, :string)
      add(:description, :text)
      add(:impact_rate, :integer)
      add(:cover, :string)
      timestamps()
    end

    create table(:test_idea_likes) do
      add(:idea_id, references(:test_ideas, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      timestamps()
    end
  end
end
