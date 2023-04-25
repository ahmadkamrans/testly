defmodule Testly.FeedbackTest do
  use Testly.DataCase, async: true

  alias Testly.Feedback
  alias Testly.Feedback.{Poll, ShortTextQuestion, LongTextQuestion, Response, Answer}

  describe "#get_poll/1" do
    setup [:insert_project]

    test "works", %{project: project} do
      response_uuid = Ecto.UUID.generate()
      question_uuid = Ecto.UUID.generate()

      poll =
        insert(:feedback_poll,
          project_id: project.id,
          question_schemas: [
            build(:feedback_short_text_question_schema, id: question_uuid, index: 0),
            build(:feedback_long_text_question_schema, index: 1)
          ],
          responses: [
            build(:feedback_response, id: response_uuid)
          ]
        )

      insert(:feedback_answer, response_id: response_uuid, question_id: question_uuid)

      result = Feedback.get_poll(poll.id)

      assert %Poll{
               questions: [
                 %ShortTextQuestion{},
                 %LongTextQuestion{}
               ],
               responses: [
                 %Response{
                   answers: [
                     %Answer{}
                   ]
                 }
               ]
             } = result
    end
  end

  describe "#get_polls/2" do
    setup [:insert_project]

    test "works", %{project: project} do
      insert_list(2, :feedback_poll,
        project_id: project.id,
        question_schemas: [
          build(:feedback_short_text_question_schema, index: 0)
        ]
      )

      result = Feedback.get_polls(project)

      assert [%Poll{}, %Poll{}] = result
    end
  end

  describe "#create_poll/2" do
    setup [:insert_project]

    test "valid params", %{project: project} do
      params = %{
        name: "Poll name",
        is_active: true,
        thank_you_message: "Thank you!",
        questions: [
          %{
            type: :short_text,
            title: "Short?"
          },
          %{
            type: "long_text",
            title: "Long?"
          }
        ]
      }

      result = Feedback.create_poll(project, params)

      assert {:ok,
              %Poll{
                questions: [
                  %ShortTextQuestion{},
                  %LongTextQuestion{}
                ]
              }} = result
    end

    test "invalid params", %{project: project} do
      params = %{}

      result = Feedback.create_poll(project, params)

      assert {:error, %Changeset{}} = result
    end
  end

  describe "#update_poll/2" do
    setup [:insert_project, :insert_poll]

    test "valid params", %{poll: poll} do
      params = %{
        name: "Updated name",
        questions: [
          %{
            type: :short_text,
            title: "Short?"
          }
        ]
      }

      result = Feedback.update_poll(poll, params)

      assert {:ok,
              %Poll{
                name: "Updated name",
                questions: [
                  %ShortTextQuestion{}
                ]
              }} = result
    end

    test "invalid params", %{poll: poll} do
      params = %{name: ""}

      result = Feedback.update_poll(poll, params)

      assert {:error, %Changeset{}} = result
    end
  end

  defp insert_poll(%{project: project}) do
    poll =
      insert(:feedback_poll,
        project_id: project.id,
        question_schemas: [
          build(:feedback_short_text_question_schema, index: 0),
          build(:feedback_long_text_question_schema, index: 1)
        ]
      )

    %{
      poll: Feedback.get_poll(poll.id)
    }
  end
end
