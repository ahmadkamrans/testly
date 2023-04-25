defmodule Testly.SplitTests.VariationReportDbDumper do
  use GenServer, shutdown: 5000

  require Logger

  alias Testly.Repo
  alias Testly.SplitTests
  alias Testly.SplitTests.GoalVariationReport
  alias Testly.Goals

  @frequence_seconds 60

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)

    send(self(), :dump)

    {:ok, nil}
  end

  def handle_info(:dump, state) do
    Logger.info("Variation report dump started")

    Repo.transaction(
      fn ->
        SplitTests.stream_all_split_tests(statuses: [:active, :finished])
        |> Stream.each(fn split_test ->
          split_test = SplitTests.preload_all(split_test)
          goals = Goals.get_goals(split_test)

          for goal <- goals do
            for variation <- split_test.variations do
              GoalVariationReport.generate_report(goal, variation)
              |> GoalVariationReport.put_rates_by_date_reports(
                goal,
                variation,
                DateTime.to_date(split_test.created_at),
                if(split_test.finished_at, do: DateTime.to_date(split_test.finished_at), else: Date.utc_today())
              )
            end
            |> GoalVariationReport.put_improvement_rate()
            |> Enum.each(
              &Repo.insert!(&1,
                on_conflict: :replace_all,
                conflict_target: [:goal_id, :variation_id]
              )
            )
          end
        end)
        |> Stream.run()
      end,
      timeout: :infinity
    )

    Logger.info("Variation report dump finished")

    delay_dump()

    {:noreply, state}
  end

  defp delay_dump do
    Process.send_after(self(), :dump, @frequence_seconds * 1000)
  end
end
