defmodule Testly.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add(:user_id, references(:users), null: false)

      add(:name, :string)
      add(:domain, :string)
      add(:is_recording_enabled, :boolean, null: false, default: true)
      add(:is_tracking_code_installed, :boolean, null: false, default: false)
      add(:is_deleted, :boolean, default: false, null: false)

      timestamps()
    end

    create(unique_index(:projects, [:domain, :user_id], where: "is_deleted=false"))
    create index(:projects, [:user_id])
    create index(:projects, [:is_deleted])
  end
end
