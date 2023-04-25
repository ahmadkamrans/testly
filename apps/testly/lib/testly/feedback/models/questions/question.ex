defmodule Testly.Feedback.Question do
  use Testly.Schema

  alias Testly.Feedback.{QuestionSchema}

  @type t ::
          ShortTextQuestion.t()
          | LongTextQuestion.t()

  @modules %{
    "short_text" => Testly.Feedback.ShortTextQuestion,
    "long_text" => Testly.Feedback.LongTextQuestion
  }

  @callback changeset(struct(), map()) :: Changeset.t()
  @callback to_question(QuestionSchema.t()) :: Question.t()

  def to_question(%QuestionSchema{type: type} = question_schema) do
    type_to_module(type).to_question(question_schema)
  end

  # def to_entry(event) do
  #   Map.take(event, [:id, :session_recording_id, :page_id, :happened_at, :type, :data, :is_processed])
  # end

  @spec create_changeset(String.t(), map()) :: Changeset.t()
  def create_changeset(poll_id, params) do
    module = type_to_module(params["type"] || params[:type])

    module
    |> struct(poll_id: poll_id)
    |> module.changeset(params)
  end

  @spec update_changeset(Question.t(), map()) :: Changeset.t()
  def update_changeset(schema, params) do
    module = type_to_module(params["type"] || params[:type])

    schema
    |> module.changeset(params)
    |> Map.put(:action, :update)
  end

  @spec delete_changeset(Question.t()) :: Changeset.t()
  def delete_changeset(schema) do
    schema
    |> Changeset.change()
    |> Map.put(:action, :delete)
  end

  @spec changesets(String.t(), [Question.t()], [map()]) :: {:ok, [Changeset.t()]} | {:error, [Changeset.t()]}
  def changesets(poll_id, questions, questions_params) do
    questions_params =
      questions_params
      |> Enum.with_index()
      |> Enum.map(fn {params, i} ->
        put_in(params[:index], i)
      end)

    update_changesets =
      for question <- questions do
        case Enum.find(questions_params, &(&1[:id] == question.id)) do
          nil -> delete_changeset(question)
          params -> update_changeset(question, params)
        end
      end

    create_changesets =
      for question_params <- questions_params, question_params[:id] == nil do
        poll_id
        |> create_changeset(question_params)
        |> Map.put(:action, :insert)
      end

    changesets = update_changesets ++ create_changesets

    invalid_changesets = Enum.filter(changesets, &(&1.valid? == false))

    if Enum.empty?(invalid_changesets) do
      {:ok, changesets}
    else
      {:error, invalid_changesets}
    end
  end

  defp type_to_module(type) do
    case @modules[to_string(type)] do
      nil -> raise "Unknown type #{inspect(type)}"
      module -> module
    end
  end

  @doc false
  defmacro __using__(_) do
    quote do
      import Testly.Feedback.Question, only: [question_model: 1]
    end
  end

  defmacro question_model(do: block) do
    quote do
      use Testly.Schema

      alias Testly.FeedbackQuestionType
      alias Testly.Feedback.{QuestionSchema, Poll}

      @behaviour Testly.Feedback.Question

      schema "feedback_questions" do
        belongs_to :poll, Poll
        field :title, :string
        field :index, :integer
        unquote(block)
      end

      @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
      def changeset(schema, params) do
        schema
        |> cast(params, [:title, :index])
        |> validate_required([:title, :index])
      end

      @spec to_question(QuestionSchema.t()) :: __MODULE__.t()
      def to_question(%QuestionSchema{} = question_schema) do
        struct(__MODULE__)
        |> cast(Map.from_struct(question_schema), [:id, :poll_id, :title, :index])
        |> Ecto.Changeset.apply_changes()
      end

      defoverridable Testly.Feedback.Question
    end
  end
end
