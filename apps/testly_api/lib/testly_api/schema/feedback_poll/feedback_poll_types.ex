defmodule TestlyAPI.Schema.FeedbackPollTypes do
  use TestlyAPI.Schema.Notation

  alias TestlyAPI.FeedbackPollResolver
  alias Testly.Feedback.{LongTextQuestion, ShortTextQuestion}

  enum(:feedback_poll_show_option,
    values: [
      :always,
      :hide_after_submit
    ]
  )

  payload_object(:feedback_poll_payload, :feedback_poll)

  input_object :feedback_poll_question_params do
    field(:id, :uuid4)
    field(:type, non_null(:string))
    field(:title, non_null(:string))
    field(:index, non_null(:integer))
  end

  input_object :feedback_poll_params do
    field(:name, non_null(:string))
    field(:is_active, non_null(:boolean))
    field(:page_matchers, non_null(list_of(non_null(:page_matcher_params))))
    field(:is_page_matcher_enabled, non_null(:boolean))
    field(:thank_you_message, non_null(:string))
    field(:questions, non_null(list_of(non_null(:feedback_poll_question_params))))
    field(:show_poll_option, non_null(:feedback_poll_show_option))
    field(:is_poll_opened_on_start, non_null(:boolean))
  end

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
      resolve(&FeedbackPollResolver.question/3)
    end
  end

  object :feedback_poll_response do
    field(:id, non_null(:uuid4))
    field(:first_interaction_at, non_null(:datetime))
    field(:created_at, non_null(:datetime))
    field(:page_url, non_null(:string))
    field(:answers, non_null(list_of(non_null(:feedback_poll_response_answer))))
    field :session_recording_id, non_null(:uuid4)

    field :feedback_poll, non_null(:feedback_poll) do
      resolve(&FeedbackPollResolver.feedback_poll/3)
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

    field :responses, non_null(:feedback_poll_response_connection) do
      arg(:pagination, :pagination)
      resolve(&FeedbackPollResolver.feedback_poll_response_connection/3)
    end
  end

  object :feedback_poll_response_connection do
    field(:nodes, non_null(list_of(non_null(:feedback_poll_response))))
    field(:total_count, non_null(:integer))
  end

  object :feedback_poll_connection do
    field(:nodes, non_null(list_of(non_null(:feedback_poll))))
    field(:total_count, non_null(:integer))

    # TODO: ask About
    # field :total_responses_count, non_null(:integer) do
    #   resolve(fn %{project: project}, _args, _resolution ->
    #     {:ok, Feedback.get_responses_count(project)}
    #   end)
    # end
  end

  object :feedback_poll_queries do
    field(:feedback_polls, non_null(:feedback_poll_connection))

    field :feedback_poll, non_null(:feedback_poll) do
      arg(:id, non_null(:uuid4))
      resolve(&FeedbackPollResolver.feedback_poll/3)
    end
  end

  object :feedback_poll_mutations do
    field :create_feedback_poll, type: :feedback_poll_payload do
      arg(:project_id, non_null(:uuid4))
      arg(:feedback_poll_params, non_null(:feedback_poll_params))
      resolve(&FeedbackPollResolver.create_feedback_poll/2)
      middleware(&build_payload/2)
    end

    field :update_feedback_poll, type: :feedback_poll_payload do
      arg(:feedback_poll_id, non_null(:uuid4))
      arg(:feedback_poll_params, non_null(:feedback_poll_params))
      resolve(&FeedbackPollResolver.update_feedback_poll/2)
      middleware(&build_payload/2)
    end

    field :delete_feedback_poll, :feedback_poll do
      arg(:id, non_null(:uuid4))
      resolve(&FeedbackPollResolver.delete_feedback_poll/2)
    end

    field :delete_feedback_poll_response, :feedback_poll_response do
      arg(:id, non_null(:uuid4))
      resolve(&FeedbackPollResolver.delete_feedback_poll_response/2)
    end
  end
end
