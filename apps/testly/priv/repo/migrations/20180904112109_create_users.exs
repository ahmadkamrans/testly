defmodule Testly.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:facebook_identifier, :string)
      add(:full_name, :string)
      add(:encrypted_password, :string)
      add(:reset_password_token, :string)
      add(:reset_password_generated_at, :utc_datetime_usec)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, :reset_password_token))
    create(unique_index(:users, [:facebook_identifier]))
  end
end
