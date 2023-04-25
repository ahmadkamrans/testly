defmodule Testly.Repo.Migrations.AddIsReadyIndex do
  use Ecto.Migration

  def change do
    create(index(:session_recordings, [:is_ready]))
  end
end
