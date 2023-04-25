defmodule Testly.Repo.Migrations.AddIconToCategory do
  use Ecto.Migration

  def change do
    alter table(:test_idea_categories) do
      add(:icon, :string)
    end
  end
end
