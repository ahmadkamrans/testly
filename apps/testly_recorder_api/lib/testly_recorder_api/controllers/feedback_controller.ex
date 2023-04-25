defmodule TestlyRecorderAPI.FeedbackController do
  use TestlyRecorderAPI, :controller
  require Logger

  alias Testly.Feedback

  def respond_to_poll(conn, %{"poll_id" => poll_id, "response" => response_params}) do
    poll = Feedback.get_poll(poll_id)

    case Feedback.respond_to_poll(poll, response_params) do
      {:ok, response} ->
        json(conn, %{responseId: response.id})

      {:error, changeset} ->
        Logger.warn("FeedbackController.respond_to_poll error - #{inspect(changeset)}")
        send_resp(conn, 422, "")
    end
  end

  def add_answer_to_response(conn, %{"response_id" => response_id, "answer" => answer_params}) do
    response = Feedback.get_response(response_id)

    case Feedback.add_answer_to_response(response, answer_params) do
      {:ok, _answer} ->
        json(conn, %{})

      {:error, changeset} ->
        Logger.warn("FeedbackController.add_answer_to_response error - #{inspect(changeset)}")
        send_resp(conn, 422, "")
    end
  end
end
