defmodule Testly.Repo.Migrations.ChangeStringTypeToText do
  use Ecto.Migration

  def change do
    alter table(:feedback_polls) do
      modify(:thank_you_message, :text)
    end

    alter table(:feedback_answers) do
      modify(:content, :text)
    end
  end
end
