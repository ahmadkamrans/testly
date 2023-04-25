defmodule Testly.SplitTestsTest do
  use Testly.DataCase, async: true
  import Testly.DataFactory

  alias Testly.SplitTests
  alias Testly.SplitTests.{SplitTest, FinishCondition, Variation}

  setup do
    project = insert(:project)
    %{project: project}
  end

  describe "#create_split_test/2" do
    test "valid", %{project: project} do
      %{id: page_type_id} = insert(:split_test_page_type)
      %{id: page_category_id} = insert(:split_test_page_category)

      params =
        string_params_for(:split_test, %{
          page_type_id: page_type_id,
          page_category_id: page_category_id
        })

      response = SplitTests.create_split_test(project, params)

      assert {:ok, %SplitTest{}} = response
    end

    test "invalid", %{project: project} do
      response = SplitTests.create_split_test(project, %{})

      assert {:error, _changeset} = response
    end
  end

  describe "#update_split_test/2" do
    test "valid", %{project: project} do
      new_name = "new name"
      %{id: id} = insert(:split_test, project_id: project.id)
      split_test = SplitTests.get_split_test(id)

      params = %{
        name: new_name,
        traffic_percent: 100,
        traffic_device_types: [:desktop],
        traffic_referrer_sources: [:direct],
        finish_condition: %{
          "type" => "visits",
          "count" => 100
        },
        variations: [
          string_params_for(:split_test_control_variation),
          string_params_for(:split_test_variation)
        ]
      }

      response = SplitTests.update_split_test(split_test, params)

      assert {:ok,
              %SplitTest{
                name: new_name,
                finish_condition: %FinishCondition{
                  type: :visits,
                  count: 100
                }
              }} = response
    end

    test "invalid", %{project: project} do
      %{id: id} = insert(:split_test, project_id: project.id)
      split_test = SplitTests.get_split_test(id)
      params = %{name: ""}

      response = SplitTests.update_split_test(split_test, params)

      assert {:error, _changeset} = response
    end
  end

  describe "#activate_split_test/1" do
    test "draft => active", %{project: project} do
      %{id: id} = insert(:split_test, project_id: project.id)
      split_test = SplitTests.get_split_test(id)

      response = SplitTests.activate_split_test(split_test)

      assert {:ok, %SplitTest{status: :active}} = response
    end
  end

  describe "#pause_split_test/1" do
    test "active => paused", %{project: project} do
      %{id: id} = insert(:active_split_test, project_id: project.id)
      split_test = SplitTests.get_split_test(id)

      response = SplitTests.pause_split_test(split_test)

      assert {:ok, %SplitTest{status: :paused}} = response
    end
  end

  describe "#finish_split_test/1" do
    test "active => finished", %{project: project} do
      %{id: id} = insert(:split_test, project_id: project.id, status: :active)
      split_test = SplitTests.get_split_test(id)

      response = SplitTests.finish_split_test(split_test)

      assert {:ok, %SplitTest{status: :finished}} = response
    end
  end

  describe "#visit_split_test_variation/2" do
    test "works", %{project: project} do
      split_test = insert(:active_split_test, project_id: project.id)
      session_recording = insert(:session_recording, project_id: project.id)
      variation_id = List.first(split_test.variations).id

      response = SplitTests.visit_split_test_variation(split_test, variation_id, session_recording)

      assert response == :ok
    end
  end

  # describe "#where_visits_to/1" do
  #   test "works", %{project: project} do
  #     session_recording = insert(:session_recording, project_id: project.id)
  #     session_recording2 = insert(:session_recording, project_id: project.id)

  #     id = Ecto.UUID.generate()

  #     insert(:active_split_test,
  #       project_id: project.id,
  #       variations: [
  #         build(:split_test_variation,
  #           visits: [
  #             build(:split_test_variation_visit, id: id, session_recording_id: session_recording.id),
  #             build(:split_test_variation_visit, session_recording_id: session_recording2.id)
  #           ]
  #         )
  #       ]
  #     )

  #     assert [queried_recording] = Repo.all(SplitTest.where_visits_to(session_recording.id))
  #     assert [variation] = queried_recording.variations
  #     assert [%Testly.SplitTests.VariationVisit{id: ^id}] = variation.visits
  #   end
  # end

  # describe "#get_visits_count/1" do
  #   test "works", %{project: project} do
  #     session_recording1 = insert(:session_recording, project_id: project.id)
  #     session_recording2 = insert(:session_recording, project_id: project.id)
  #     session_recording3 = insert(:session_recording, project_id: project.id)

  #     split_test =
  #       insert(:active_split_test,
  #         project_id: project.id,
  #         variations: [
  #           build(:split_test_variation,
  #             visits: [
  #               build(:split_test_variation_visit, session_recording_id: session_recording1.id),
  #               build(:split_test_variation_visit, session_recording_id: session_recording2.id),
  #               build(:split_test_variation_visit, session_recording_id: session_recording3.id)
  #             ]
  #           )
  #         ]
  #       )

  #     assert SplitTests.get_visits_count(split_test) === 3
  #   end
  # end

  # describe("#find_variation/2") do
  #   test "works", %{project: project} do
  #     url = "http://example.com/"

  #     insert(:active_split_test,
  #       project_id: project.id,
  #       variations: [
  #         build(:split_test_control_variation, url: url),
  #         build(:split_test_variation, url: url <> "v2")
  #       ]
  #     )

  #     response = SplitTests.find_variation(project, url)

  #     assert %Variation{url: url} = response
  #   end
  # end

  # describe "#get_goal_variation_reports/2" do
  #   test "works", %{project: project} do
  #     %{id: split_test_id} = insert(:active_split_test, project_id: project.id)
  #     insert(:split_test_path_goal, split_test_id: split_test_id)

  #     split_test = build(:split_test, variations: [
  #       build(:control_variation, id: "")
  #       build(:variation, id: "")
  #     ])
  #     goal = build(:path_goal, conversions: [
  #       build(:goal_conversion, assoc_id: "", goal_id: "", timestamp: ),
  #       build(:goal_conversion, assoc_id: "", goal_id: "", timestamp: ),
  #       build(:goal_conversion, assoc_id: "", goal_id: "", timestamp: )
  #     ])

  #     reports = SplitTests.get_goal_variation_reports(split_test, goal)
  #   end
  # end
end
