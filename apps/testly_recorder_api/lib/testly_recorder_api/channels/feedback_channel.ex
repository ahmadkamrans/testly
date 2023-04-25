# defmodule TestlyRecorderAPI.FeedbackChannel do
#   use Phoenix.Channel
#   use Appsignal.Instrumentation.Decorators
#   require Logger

#   @session_recordings Application.get_env(:testly, Testly.SessionRecordings)[:impl]

#   def join("feedback", _message, socket) do
#     {:ok, socket}
#   end

#   @decorate channel_action()
#   def handle_in("respond", %{"question_id" => question_id, "response" => response}, socket) do
#     Feedback.respond_to_question poll, question, response do
#       {:ok, _} -> true
#       {:error, _} -> false
#     end
#   end
# end
