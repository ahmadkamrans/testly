defmodule Testly.Feedback do
  alias Ecto.{Changeset, Multi}
  alias Testly.{Repo, CursorPagination}
  alias Testly.Projects.Project
  alias Testly.SessionRecordings.SessionRecording

  alias Testly.Feedback.{
    Poll,
    PollQuery,
    PollFilter,
    PollOrder,
    QuestionSchema,
    Question,
    Response,
    ResponseQuery,
    Answer
  }

  @spec get_poll(String.t()) :: Poll.t() | nil
  def get_poll(id) do
    PollQuery.from_poll()
    |> PollQuery.preload_assocs()
    |> Repo.get(id)
    |> case do
      %Poll{} = poll -> Poll.populate_questions(poll)
      nil -> nil
    end
  end

  def get_polls(%Project{id: project_id}, options \\ []) do
    filter = struct(PollFilter, options[:filter] || %{})
    order = struct(PollOrder, options[:order] || %{})
    # pagination = struct(Pagination, options[:pagination] || %{})

    PollQuery.from_poll()
    |> PollQuery.where_project_id(project_id)
    |> PollFilter.filter(filter)
    |> PollOrder.order(order)
    # |> Pagination.paginate(pagination)
    |> PollQuery.preload_assocs()
    |> Repo.all()
    |> Enum.map(&Poll.populate_questions/1)
  end

  def get_responses(_model, options \\ [])

  def get_responses(%Poll{id: poll_id}, options) do
    pagination = struct(CursorPagination, options[:pagination] || %{})

    ResponseQuery.from_response()
    |> ResponseQuery.preload_assocs()
    |> ResponseQuery.where_poll_id(poll_id)
    |> ResponseQuery.order_by_field(:desc, :created_at)
    # |> ResponseQuery.order_by_field(:asc, :id)
    |> Repo.paginate(
      cursor_fields: [:created_at],
      limit: pagination.limit,
      before: pagination.before,
      after: pagination.after,
      sort_direction: :desc
    )
  end

  def get_responses(%SessionRecording{id: session_recording_id}, _options) do
    ResponseQuery.from_response()
    |> ResponseQuery.where_session_recording_id(session_recording_id)
    |> ResponseQuery.order_by_field(:desc, :first_interaction_at)
    |> ResponseQuery.preload_assocs()
    |> Repo.all()
  end

  def get_active_polls(%Project{id: project_id}) do
    PollQuery.from_poll()
    |> PollQuery.where_project_id(project_id)
    |> PollQuery.where_active()
    |> PollQuery.preload_assocs()
    |> Repo.all()
    |> Enum.map(&Poll.populate_questions/1)
  end

  @spec get_active_polls_count(Project.t()) :: non_neg_integer()
  def get_active_polls_count(%Project{id: project_id}) do
    PollQuery.from_poll()
    |> PollQuery.where_project_id(project_id)
    |> PollQuery.where_active()
    |> Repo.aggregate(:count, :id)
  end

  @spec get_polls_count(Project.t()) :: non_neg_integer()
  def get_polls_count(%Project{id: project_id}) do
    PollQuery.from_poll()
    |> PollQuery.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  @spec get_responses_count(Project.t()) :: non_neg_integer()
  def get_responses_count(%Project{id: project_id}) do
    PollQuery.from_poll()
    |> PollQuery.join_responses()
    |> PollQuery.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  @spec get_responses_count(Poll.t()) :: non_neg_integer()
  def get_responses_count(%Poll{id: id}) do
    ResponseQuery.from_response()
    |> ResponseQuery.where_poll_id(id)
    |> Repo.aggregate(:count, :id)
  end

  @spec get_response(String.t()) :: Response.t() | nil
  def get_response(id) do
    Repo.get(Response, id)
  end

  @spec get_question(Answer.t()) :: Question.t() | nil
  def get_question(%Answer{question_id: question_id}) do
    Repo.get_by(QuestionSchema, id: question_id)
    |> case do
      nil -> nil
      schema -> Question.to_question(schema)
    end
  end

  @spec create_poll(Project.t(), map()) :: {:ok, Poll.t()} | {:error, Changeset.t()}
  def create_poll(%Project{id: project_id}, params) do
    result =
      Multi.new()
      |> Multi.run(:poll, fn _repo, _changes ->
        %Poll{project_id: project_id}
        |> Poll.changeset(params)
        |> Repo.insert()
      end)
      |> Multi.run(:questions, fn _repo, %{poll: poll} ->
        if params[:questions] do
          update_questions(poll, params[:questions])
        else
          {:ok, :questions}
        end
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{poll: poll, questions: _questions}} ->
        {:ok, get_poll(poll.id)}

      {:error, :poll, changeset, _changes} ->
        {:error, changeset}

      {:error, :questions, changesets, _changes} ->
        {:error, changesets}
    end
  end

  @spec update_poll(Poll.t(), map()) :: {:ok, Poll.t()} | {:error, Changeset.t()}
  def update_poll(poll, params) do
    result =
      Multi.new()
      |> Multi.run(:poll, fn _repo, _changes ->
        poll
        |> Poll.changeset(params)
        |> Repo.update()
      end)
      |> Multi.run(:questions, fn _repo, %{poll: poll} ->
        if params[:questions] do
          update_questions(poll, params[:questions])
        else
          {:ok, :questions}
        end
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{poll: poll, questions: _questions}} ->
        {:ok, get_poll(poll.id)}

      {:error, :poll, changeset, _changes} ->
        {:error, changeset}

      {:error, :questions, changesets, _changes} ->
        {:error, changesets}
    end
  end

  defp update_questions(poll, questions_params) do
    questions = poll.questions

    case Question.changesets(poll.id, questions, questions_params) do
      {:ok, changesets} ->
        for changeset <- changesets do
          question = Changeset.apply_changes(changeset)

          case changeset do
            %{action: :insert} ->
              %QuestionSchema{}
              |> QuestionSchema.changeset(question)
              |> Repo.insert!()

            %{action: :update} ->
              QuestionSchema
              |> Repo.get(question.id)
              |> QuestionSchema.changeset(question)
              |> Repo.update!()

            %{action: :delete} ->
              QuestionSchema
              |> Repo.get(question.id)
              |> Repo.delete!()
          end
        end

        {:ok, :questions}

      {:error, _} = error ->
        error
    end
  end

  @spec delete_poll(Poll.t()) :: Poll.t()
  def delete_poll(poll) do
    Repo.delete!(poll)
  end

  @spec delete_response(Response.t()) :: Response.t()
  def delete_response(response) do
    Repo.delete!(response)
  end

  @spec respond_to_poll(Poll.t(), map()) :: {:ok, Response.t()} | {:error, Changeset.t()}
  def respond_to_poll(poll, params) do
    %Response{poll_id: poll.id}
    |> Response.changeset(params)
    |> Repo.insert()
  end

  @spec add_answer_to_response(Response.t(), map()) :: {:ok, Answer.t()} | {:error, Changeset.t()}
  def add_answer_to_response(response, params) do
    %Answer{response_id: response.id}
    |> Answer.changeset(params)
    |> Repo.insert()
  end
end
