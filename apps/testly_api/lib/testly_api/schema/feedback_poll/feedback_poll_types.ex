defmodule TestlyAPI.Schema.FeedbackPollTypes do
  use Absinthe.Schema.Notation

  alias Testly.Feedback
  alias Testly.Feedback.{LongTextQuestion, ShortTextQuestion}
  alias Testly.Projects.Project

  enum(:feedback_poll_show_option,
    values: [
      :always,
      :hide_after_submit
    ]
  )

  object :feedback_poll_short_text_question do
    field(:id, non_null(:uuid4))
    field(:title, non_null(:string))
    field(:index, non_null(:integer))
  end

  object :feedback_poll_long_text_question do
    field(:id, non_null(:uuid4))
    field(:title, non_null(:string))
    field(:index, non_null(:integer))
  end

  union :feedback_poll_question do
    types([:feedback_poll_short_text_question, :feedback_poll_long_text_question])

    resolve_type(fn
      %ShortTextQuestion{}, _ -> :feedback_poll_short_text_question
      %LongTextQuestion{}, _ -> :feedback_poll_long_text_question
    end)
  end

  object :feedback_poll_response_answer do
    field(:id, non_null(:uuid4))
    field(:content, non_null(:string))
    field(:answered_at, non_null(:datetime))

    field :question, non_null(:feedback_poll_question) do
      resolve(fn answer, _args, _resolution ->
        {:ok, Feedback.get_question(answer)}
      end)
    end
  end

  object :feedback_poll_response do
    field(:id, non_null(:uuid4))
    field(:first_interaction_at, non_null(:datetime))
    field(:created_at, non_null(:datetime))
    field(:page_url, non_null(:string))
    field(:answers, non_null(list_of(non_null(:feedback_poll_response_answer))))

    field :session_recording, :session_recording do
      resolve(fn response, _args, _resolution ->
        # Just avoid excess preload, cause frontend need only id of session recording
        {:ok, %{id: response.session_recording_id}}
      end)
    end

    field :feedback_poll, non_null(:feedback_poll) do
      resolve(fn response, _args, _resolution ->
        {:ok, Feedback.get_poll(response.poll_id)}
      end)
    end
  end

  object :feedback_poll do
    field(:id, non_null(:uuid4))
    field(:name, non_null(:string))
    field(:is_active, non_null(:boolean))
    field(:thank_you_message, non_null(:string))
    field(:questions, non_null(list_of(non_null(:feedback_poll_question))))
    field(:page_matchers, non_null(list_of(non_null(:page_matcher))))
    field(:is_page_matcher_enabled, non_null(:boolean))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
    field(:show_poll_option, non_null(:feedback_poll_show_option))
    field(:is_poll_opened_on_start, non_null(:boolean))

    field :responses, non_null(:feedback_poll_responses_connection) do
      arg(:pagination, :cursor_pagination)

      resolve(fn poll, args, _resolution ->
        %{entries: entries, metadata: metadata} =
          Feedback.get_responses(
            poll,
            pagination: args[:pagination]
          )

        {:ok, %{nodes: entries, page_info: metadata}}
      end)
    end

    field :responses_count, non_null(:integer) do
      resolve(fn poll, _args, _resolution ->
        {:ok, Feedback.get_responses_count(poll)}
      end)
    end
  end

  object :feedback_poll_responses_connection do
    field :nodes, non_null(list_of(non_null(:feedback_poll_response)))
    field :page_info, non_null(:cursor_page_info)
  end

  object :project_feedback_polls_connection do
    field :nodes, non_null(list_of(non_null(:feedback_poll))) do
      resolve(fn %{project: project}, _args, _resolution ->
        {:ok, Feedback.get_polls(project)}
      end)
    end

    field :total_records, non_null(:integer) do
      resolve(fn %{project: project}, _args, _resolution ->
        {:ok, Feedback.get_polls_count(project)}
      end)
    end

    field :active_polls_count, non_null(:integer) do
      resolve(fn %{project: project}, _args, _resolution ->
        {:ok, Feedback.get_active_polls_count(project)}
      end)
    end

    field :responses_count, non_null(:integer) do
      resolve(fn %{project: project}, _args, _resolution ->
        {:ok, Feedback.get_responses_count(project)}
      end)
    end
  end

  object :feedback_poll_queries do
    field :feedback_polls, non_null(:project_feedback_polls_connection) do
      resolve(fn project, _data, _context ->
        {:ok,
         %{
           project: project
         }}
      end)
    end

    field :feedback_poll, non_null(:feedback_poll) do
      arg(:id, non_null(:uuid4))

      resolve(fn %Project{} = _project, %{id: id}, %{context: %{current_project_user: _current_project_user}} ->
        {:ok, Feedback.get_poll(id)}
      end)
    end
  end
end
