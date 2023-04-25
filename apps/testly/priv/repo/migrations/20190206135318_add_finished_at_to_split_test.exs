defmodule Testly.Repo.Migrations.AddFinishedAtToSplitTest do
  use Ecto.Migration

  def change do
    alter table(:split_tests) do
      add(:finished_at, :utc_datetime)
    end
  end
end
