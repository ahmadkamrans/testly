defmodule Testly.Repo.Migrations.AddProfileFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:company_name, :string)
      add(:phone, :string)
    end
  end
end
