defmodule TestlyAPI.Schema.FeedbackPoll.MutationTypes do
  use Absinthe.Schema.Notation

  import(Kronky.Payload, only: :functions)
  import(TestlyAPI.Schema.Payload)

  alias Testly.Feedback
  alias Testly.Projects.Project

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

  object :feedback_poll_mutations do
    field :create_feedback_poll, type: :feedback_poll_payload do
      arg(:project_id, non_null(:uuid4))
      arg(:feedback_poll_params, non_null(:feedback_poll_params))

      resolve(fn %{feedback_poll_params: feedback_poll_params, project_id: project_id},
                 %{context: %{current_project_user: _current_project_user}} ->
        map_error_to_ok(Feedback.create_poll(%Project{id: project_id}, feedback_poll_params))
      end)

      middleware(&build_payload/2)
    end

    field :update_feedback_poll, type: :feedback_poll_payload do
      arg(:feedback_poll_id, non_null(:uuid4))
      arg(:feedback_poll_params, non_null(:feedback_poll_params))

      resolve(fn %{feedback_poll_params: feedback_poll_params, feedback_poll_id: feedback_poll_id},
                 %{context: %{current_project_user: _current_project_user}} ->
        map_error_to_ok(
          Feedback.update_poll(
            Feedback.get_poll(feedback_poll_id),
            feedback_poll_params
          )
        )
      end)

      middleware(&build_payload/2)
    end

    field :delete_feedback_poll, :feedback_poll do
      arg(:id, non_null(:uuid4))

      resolve(fn %{id: feedback_poll_id}, %{context: %{current_project_user: _current_project_user}} ->
        {:ok, Feedback.delete_poll(Feedback.get_poll(feedback_poll_id))}
      end)
    end

    field :delete_feedback_poll_response, :feedback_poll_response do
      arg(:id, non_null(:uuid4))

      resolve(fn %{id: response_id}, %{context: %{current_project_user: _current_project_user}} ->
        {:ok, Feedback.delete_response(Feedback.get_response(response_id))}
      end)
    end
  end

  @spec map_error_to_ok({:error, any()} | {:ok, any()}) :: {:ok, any()}
  defp map_error_to_ok({:error, data}), do: {:ok, data}
  defp map_error_to_ok({:ok, data}), do: {:ok, data}
end
