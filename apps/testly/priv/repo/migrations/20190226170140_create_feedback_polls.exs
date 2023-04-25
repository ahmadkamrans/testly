defmodule Testly.Repo.Migrations.CreateFeedbackPolls do
  use Ecto.Migration

  def change do
    create table(:feedback_polls) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:name, :string)
      add(:thank_you_message, :string, default: "")
      add(:is_active, :boolean, default: false)
      add(:is_page_matcher_enabled, :boolean, default: false)
      add(:page_matchers, {:array, :map})
      timestamps()
    end

    create(index(:feedback_polls, [:project_id]))

    create table(:feedback_questions) do
      add(:poll_id, references(:feedback_polls, on_delete: :delete_all), null: false)
      add(:type, :string)
      add(:title, :string)
      add(:index, :integer)
      add(:data, :map)
    end

    create(index(:feedback_questions, [:poll_id]))

    create table(:feedback_responses) do
      add(:poll_id, references(:feedback_polls, on_delete: :delete_all), null: false)
      add(:session_recording_id, references(:session_recordings, on_delete: :nilify_all))
      add(:page_url, :string)
      timestamps()
    end

    create(index(:feedback_responses, [:poll_id]))
    create(index(:feedback_responses, [:session_recording_id]))

    create table(:feedback_answers) do
      add(:response_id, references(:feedback_responses, on_delete: :delete_all), null: false)
      add(:question_id, references(:feedback_questions, on_delete: :delete_all), null: false)
      add(:content, :string)
    end

    create(index(:feedback_answers, [:response_id]))
    create(index(:feedback_answers, [:question_id]))
    create(unique_index(:feedback_answers, [:response_id, :question_id]))
  end
end
