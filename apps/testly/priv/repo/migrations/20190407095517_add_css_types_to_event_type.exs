defmodule Testly.Repo.Migrations.AddCSSTypesToEventType do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute "ALTER TYPE session_recordings_event_type_enum ADD VALUE IF NOT EXISTS 'css_rule_inserted'"
    Ecto.Migration.execute "ALTER TYPE session_recordings_event_type_enum ADD VALUE IF NOT EXISTS 'css_rule_deleted'"
  end

  def down do
  end
end
