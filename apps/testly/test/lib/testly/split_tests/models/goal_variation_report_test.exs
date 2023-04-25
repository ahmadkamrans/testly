defmodule Testly.SplitTests.GoalVariationReportTest do
  use Testly.DataCase
  import Testly.DataFactory

  alias Testly.SplitTests.GoalVariationReport

  def generate_data(_) do
    visit1_id = Ecto.UUID.generate()
    visit3_id = Ecto.UUID.generate()

    first_visited_at = ~N[2000-01-01 10:00:00.000000Z] |> DateTime.from_naive!("Etc/UTC")
    second_visited_at = ~N[2000-01-02 15:00:00.000000Z] |> DateTime.from_naive!("Etc/UTC")
    third_visited_at = ~N[2000-01-03 11:00:00.000000Z] |> DateTime.from_naive!("Etc/UTC")

    first_session_recording_id = Ecto.UUID.generate()
    second_session_recording_id = Ecto.UUID.generate()
    third_session_recording_id = Ecto.UUID.generate()

    variation =
      build(:split_test_variation,
        visits: [
          build(:split_test_variation_visit,
            id: visit1_id,
            session_recording_id: first_session_recording_id,
            visited_at: first_visited_at
          ),
          build(:split_test_variation_visit,
            session_recording_id: first_session_recording_id,
            visited_at: first_visited_at
          ),
          build(:split_test_variation_visit,
            id: visit3_id,
            session_recording_id: second_session_recording_id,
            visited_at: second_visited_at
          ),
          build(:split_test_variation_visit,
            session_recording_id: third_session_recording_id,
            visited_at: third_visited_at
          )
        ]
      )

    goal =
      build(:path_goal,
        value: Decimal.from_float(1.0),
        conversions: [
          build(:goal_conversion, assoc_id: visit1_id),
          build(:goal_conversion, assoc_id: visit3_id)
        ]
      )

    %{goal: goal, variation: variation}
  end

  describe "put_rates_by_date_reports/3" do
    setup :generate_data

    test "generates rates by date", %{goal: goal, variation: variation} do
      assert [
               %GoalVariationReport.RateByDateReport{
                 date: ~D[1999-12-31],
                 conversion_rate: 0.0
               },
               %GoalVariationReport.RateByDateReport{
                 date: ~D[2000-01-01],
                 conversion_rate: 50.0
               },
               %GoalVariationReport.RateByDateReport{
                 date: ~D[2000-01-02],
                 conversion_rate: 100.0
               },
               %GoalVariationReport.RateByDateReport{
                 date: ~D[2000-01-03],
                 conversion_rate: 0.0
               },
               %GoalVariationReport.RateByDateReport{
                 date: ~D[2000-01-04],
                 conversion_rate: 0.0
               }
             ] ===
               GoalVariationReport.put_rates_by_date_reports(
                 %GoalVariationReport{},
                 goal,
                 variation,
                 ~D[1999-12-31],
                 ~D[2000-01-04]
               ).rates_by_date
    end
  end

  describe "generate_report/2" do
    setup :generate_data

    test "generates general report", %{goal: goal, variation: variation} do
      revenue = Decimal.from_float(2.0)

      assert %GoalVariationReport{
               visits_count: 4,
               conversions_count: 2,
               conversion_rate: 50.0,
               revenue: ^revenue,
               control: false
             } = GoalVariationReport.generate_report(goal, variation)
    end

    test "works with empty visits and conversions" do
      variation =
        build(:split_test_variation,
          visits: []
        )

      goal =
        build(:path_goal,
          conversions: []
        )

      response = GoalVariationReport.generate_report(goal, variation)

      revenue = Decimal.from_float(0.0)

      assert %GoalVariationReport{
               visits_count: 0,
               conversions_count: 0,
               conversion_rate: 0.0,
               revenue: ^revenue
             } = response
    end
  end

  describe "put_is_winner/2" do
    test "works when is_finished" do
      assert GoalVariationReport.put_is_winner(
               [
                 %GoalVariationReport{
                   conversion_rate: 20.0
                 },
                 %GoalVariationReport{
                   conversion_rate: 10.0
                 },
                 %GoalVariationReport{
                   conversion_rate: 30.0
                 }
               ],
               true
             ) === [
               %GoalVariationReport{
                 conversion_rate: 20.0,
                 is_winner: false
               },
               %GoalVariationReport{
                 conversion_rate: 10.0,
                 is_winner: false
               },
               %GoalVariationReport{
                 conversion_rate: 30.0,
                 is_winner: true
               }
             ]
    end

    test "no winner when the same conversion_rate when is_finished" do
      assert GoalVariationReport.put_is_winner(
               [
                 %GoalVariationReport{
                   conversion_rate: 20.0
                 },
                 %GoalVariationReport{
                   conversion_rate: 20.0
                 }
               ],
               true
             ) === [
               %GoalVariationReport{
                 conversion_rate: 20.0,
                 is_winner: false
               },
               %GoalVariationReport{
                 conversion_rate: 20.0,
                 is_winner: false
               }
             ]
    end

    test "sets all to false when not is_finished" do
      assert GoalVariationReport.put_is_winner(
               [
                 %GoalVariationReport{
                   conversion_rate: 20.0
                 },
                 %GoalVariationReport{
                   conversion_rate: 10.0
                 },
                 %GoalVariationReport{
                   conversion_rate: 30.0
                 }
               ],
               false
             ) === [
               %GoalVariationReport{
                 conversion_rate: 20.0,
                 is_winner: false
               },
               %GoalVariationReport{
                 conversion_rate: 10.0,
                 is_winner: false
               },
               %GoalVariationReport{
                 conversion_rate: 30.0,
                 is_winner: false
               }
             ]
    end
  end

  describe "put_improvement_rate/1" do
    test "works" do
      assert GoalVariationReport.put_improvement_rate([
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: true
               },
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: false
               }
             ]) === [
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: true,
                 improvement_rate: nil
               },
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: false,
                 improvement_rate: 0.0
               }
             ]

      assert GoalVariationReport.put_improvement_rate([
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: true
               },
               %GoalVariationReport{
                 conversion_rate: 0.50,
                 control: false
               }
             ]) === [
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: true,
                 improvement_rate: nil
               },
               %GoalVariationReport{
                 conversion_rate: 0.50,
                 control: false,
                 improvement_rate: 400.0
               }
             ]

      assert GoalVariationReport.put_improvement_rate([
               %GoalVariationReport{
                 conversion_rate: 0.20,
                 control: true
               },
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: false,
                 improvement_rate: nil
               }
             ]) === [
               %GoalVariationReport{
                 conversion_rate: 0.20,
                 control: true
               },
               %GoalVariationReport{
                 conversion_rate: 0.10,
                 control: false,
                 improvement_rate: -50.0
               }
             ]

      assert GoalVariationReport.put_improvement_rate([
               %GoalVariationReport{
                 conversion_rate: 0.0,
                 control: true
               },
               %GoalVariationReport{
                 conversion_rate: 0.5,
                 control: false
               }
             ]) === [
               %GoalVariationReport{
                 conversion_rate: 0.0,
                 control: true,
                 improvement_rate: nil
               },
               %GoalVariationReport{
                 conversion_rate: 0.5,
                 control: false,
                 improvement_rate: nil
               }
             ]
    end
  end
end
