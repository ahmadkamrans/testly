defmodule Testly.Repo.Migrations.ChangePolls do
  use Ecto.Migration

  alias Testly.PollShowOption

  def up do
    PollShowOption.create_type()

    alter table(:feedback_polls) do
      add(:show_poll_option, PollShowOption.type(), default: "hide_after_submit")
      add(:is_poll_opened_on_start, :boolean, default: false)
    end
  end

  def down do
    PollShowOption.drop_type()

    alter table(:feedback_polls) do
      remove(:show_poll_option)
      remove(:is_poll_opened_on_start)
    end
  end
end
