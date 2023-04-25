defmodule Testly.Repo.Migrations.AddUploadedScriptHashToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:uploaded_script_hash, :string)
    end
  end
end
