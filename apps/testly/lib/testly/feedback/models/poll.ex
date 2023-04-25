defmodule Testly.Feedback.Poll do
  use Testly.Schema

  alias __MODULE__
  alias Testly.Feedback.{Question, QuestionSchema, PageMatcher, Response}

  @type t :: %__MODULE__{
          project_id: Testly.Schema.pk(),
          name: String.t(),
          is_active: boolean(),
          is_page_matcher_enabled: boolean(),
          thank_you_message: String.t(),
          questions: [Question.t()],
          page_matchers: [PageMatcher.t()],
          responses: [Response.t()]
        }

  schema "feedback_polls" do
    has_many(:question_schemas, QuestionSchema)
    has_many(:responses, Response)
    embeds_many :page_matchers, PageMatcher, on_replace: :delete
    field(:questions, {:array, :map}, virtual: true, default: [])
    field(:project_id, Ecto.UUID)
    field(:name, :string)
    field(:is_active, :boolean, default: false)
    field(:is_page_matcher_enabled, :boolean, default: false)
    field(:thank_you_message, :string, default: "")
    field :show_poll_option, Testly.PollShowOption, default: :always
    field :is_poll_opened_on_start, :boolean, default: false

    timestamps()
  end

  @spec changeset(Poll.t(), map()) :: Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [
      :name,
      :is_active,
      :thank_you_message,
      :is_page_matcher_enabled,
      :show_poll_option,
      :is_poll_opened_on_start
    ])
    |> validate_required([
      :name,
      :is_active,
      :thank_you_message,
      :is_page_matcher_enabled,
      :show_poll_option,
      :is_poll_opened_on_start
    ])
    |> cast_embed(:page_matchers)
  end

  @spec populate_questions(Poll.t()) :: Poll.t()
  def populate_questions(poll) do
    questions = Enum.map(poll.question_schemas, &Question.to_question/1)

    %{poll | questions: questions}
  end
end
