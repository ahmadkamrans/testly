defmodule TestlyAPI.FeedbackPollResolver do
  use TestlyAPI.Resolver
  alias Testly.Feedback
  alias Testly.Projects.Project

  def feedback_poll_response_connection(poll, args, _res) do
    {:ok,
     %{
       nodes: Feedback.get_responses(poll, args),
       # Feedback.get_responses_count(poll)
       total_count: 10
     }}
  end

  def feedback_poll(_parent, %{id: id}, _res) do
    {:ok, Feedback.get_poll(id)}
  end

  def feedback_poll(response, _args, _resolution) do
    {:ok, Feedback.get_poll(response.poll_id)}
  end

  def question(answer, _args, _resolution) do
    {:ok, Feedback.get_question(answer)}
  end

  def create_feedback_poll(%{feedback_poll_params: feedback_poll_params, project_id: project_id}, _res) do
    %Project{id: project_id}
    |> Feedback.create_poll(feedback_poll_params)
    |> map_error_to_ok
  end

  def update_feedback_poll(
        %{feedback_poll_params: feedback_poll_params, feedback_poll_id: feedback_poll_id},
        _res
      ) do
    Feedback.get_poll(feedback_poll_id)
    |> Feedback.update_poll(feedback_poll_params)
    |> map_error_to_ok
  end

  def delete_feedback_poll(%{id: feedback_poll_id}, _res) do
    {:ok, Feedback.delete_poll(Feedback.get_poll(feedback_poll_id))}
  end

  def delete_feedback_poll_response(%{id: response_id}, _res) do
    {:ok, Feedback.delete_response(Feedback.get_response(response_id))}
  end
end
