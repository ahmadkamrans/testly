defmodule Testly.GoalsTest do
  use Testly.DataCase, async: true
  import Testly.DataFactory

  alias Testly.Goals
  alias Testly.Goals.{Goal, Conversion}

  setup do
    project = insert(:project)
    session_recording = insert(:session_recording, project_id: project.id)

    split_test =
      insert(:split_test,
        project_id: project.id,
        variations: [
          build(:split_test_variation,
            visits: [build(:split_test_variation_visit, session_recording_id: session_recording.id)]
          )
        ]
      )

    %{variations: [%{visits: [variation_visit]}]} = split_test

    %{
      project: project,
      split_test: split_test,
      session_recording: session_recording,
      variation_visit: variation_visit
    }
  end

  describe "#get_goal/1" do
    test "returns goal", %{project: project, session_recording: session_recording} do
      %{id: id} =
        insert(:path_goal,
          project_id: project.id,
          conversions: [
            build(:goal_conversion, session_recording_id: session_recording.id)
          ]
        )

      response = Goals.get_goal(id)

      assert %Goal{
               conversions: [%Conversion{}]
             } = response
    end
  end

  # describe "#get_goals/2" do
  #   test "Project", %{project: project} do
  #     insert(:project_path_goal, project_id: project.id)

  #     response = Goals.get_goals(project)

  #     assert [%PathGoal{}] = response
  #   end

  #   test "SplitTest", %{split_test: split_test} do
  #     insert(:split_test_path_goal, split_test_id: split_test.id)

  #     response = Goals.get_goals(split_test)

  #     assert [%PathGoal{}] = response
  #   end
  # end

  describe "#create_goal/2" do
    test "ok", %{project: project} do
      params = string_params_for(:path_goal, %{value: 0})

      response = Goals.create_goal(project, params)

      assert {:ok, %Goal{} = goal} = response
    end

    test "error", %{project: project} do
      params = %{}

      response = Goals.create_goal(project, params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "#update_goal/2" do
    test "ok", %{project: project} do
      goal = insert(:path_goal, project_id: project.id)
      params = %{name: "updated goal"}

      response = Goals.update_goal(goal, params)

      assert {:ok, %Goal{name: "updated goal"} = goal} = response
    end
  end

  describe "#delete_goal/1" do
    test "ok", %{project: project} do
      goal = insert(:path_goal, project_id: project.id)

      response = Goals.delete_goal(goal)

      assert {:ok, %Goal{}} = response
    end
  end

  describe "#convert_goals/1" do
    test "ok", %{project: project} do
      goal = insert(:path_goal, project_id: project.id)

      session_recording =
        insert(:session_recording, %{
          project_id: project.id,
          pages: [
            build(:session_recording_page, url: List.first(goal.path).url)
          ]
        })

      response = Goals.convert_goals(session_recording)

      updated_goal = Goals.get_goal(goal.id)
      assert :ok = response
      assert 1 = Enum.count(updated_goal.conversions)
    end
  end

  # describe "#get_split_test_goal_conversions_count/1" do
  #   test "works", %{
  #     split_test: split_test,
  #     variation_visit: variation_visit
  #   } do
  #     %{id: goal_id} = insert(:split_test_path_goal, split_test_id: split_test.id)
  #     assert Goals.get_split_test_goal_conversions_count(goal_id) === 0

  #     insert(:split_test_goal_conversion, split_test_goal_id: goal_id, split_test_variation_visit_id: variation_visit.id)

  #     assert Goals.get_split_test_goal_conversions_count(goal_id) === 1
  #   end
  # end

  #   describe "#session_recordings_with_goals_count" do
  #     test "works", %{project: project} do
  #       # count data
  #       session_recordings = insert_list(2, :session_recording)
  #       insert_list(2, :goal, project: project, session_recordings: session_recordings)
  #       # noise data
  #       insert(:session_recording)
  #       insert(:goal, project: project)

  #       response = Goals.session_recordings_with_goals_count(project.id)

  #       assert response == 4
  #     end
  #   end

  #   describe "#reach_goal_for_session_recordings/2" do
  #     setup [:insert_goal, :insert_session_recording]

  #     test "ok", %{goal: goal, session_recording: session_recording} do
  #       :ok = Goals.reach_goal_for_session_recordings(goal.id)

  #       assert %GoalSessionRecording{} = Repo.get_by(GoalSessionRecording, goal_id: goal.id, session_recording_id: session_recording.id)
  #     end
  #   end

  #   describe "#reach_goals_for_session_recording/2" do
  #     setup [:insert_goal, :insert_session_recording]

  #     test "ok", %{goal: goal, session_recording: session_recording} do
  #       :ok = Goals.reach_goals_for_session_recording(session_recording.id)

  #       assert %GoalSessionRecording{} = Repo.get_by(GoalSessionRecording, goal_id: goal.id, session_recording_id: session_recording.id)
  #     end
  #   end

  #   defp insert_session_recording(%{project: project}) do
  #     session_recording = insert(:session_recording,
  #       project: project,
  #       pages: build_list(1, :page, %{
  #         url: @url
  #       })
  #     )
  #     %{session_recording: session_recording}
  #   end

  #   defp insert_goal(%{project: project}) do
  #     goal = insert(:goal,
  #         project: project,
  #         path: build_list(1, :path_step, %{
  #           index: 0,
  #           url: @url,
  #           match_type: :contains
  #         })
  #       )
  #     %{goal: goal}
  #   end

  # defp insert_project(_context) do
  #   project = insert(:project)
  #   %{project: project}
  # end

  # defp insert_split_test(%{project: project}) do
  #   split_test = insert(:split_test, project_id: project.id)
  #   %{split_test: split_test}

  #   insert(:session_recording)
  # end
end
