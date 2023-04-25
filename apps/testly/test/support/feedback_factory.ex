defmodule Testly.FeedbackFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Feedback.{
        Poll,
        QuestionSchema,
        ShortTextQuestion,
        LongTextQuestion,
        Response,
        Answer
      }

      def feedback_poll_factory do
        %Poll{
          name: "Feedback Poll",
          thank_you_message: "Thanks!"
        }
      end

      def feedback_response_factory do
        %Response{
          page_url: "https://example.com",
          first_interaction_at: DateTime.utc_now()
        }
      end

      def feedback_answer_factory do
        %Answer{
          content: "answer",
          answered_at: DateTime.utc_now()
        }
      end

      def feedback_short_text_question_schema_factory do
        %QuestionSchema{
          title: "title",
          type: :short_text
        }
      end

      def feedback_long_text_question_schema_factory do
        %QuestionSchema{
          title: "title",
          type: :long_text
        }
      end
    end
  end
end
