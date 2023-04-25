defmodule Testly.SplitTests.Worker do
  @behaviour Honeydew.Worker
  @queue :split_tests_queue
  require Logger

  alias Testly.SplitTests

  alias Testly.SplitTests.{
    SplitTest,
    FinishCondition
  }

  def enqueue_maybe_finish_split_test(
        %SplitTest{
          id: id,
          finish_condition: %FinishCondition{type: :days_passed, count: count},
          created_at: created_at
        } = split_test
      ) do
    # TODO:  What to do when we deleted the split test, we want to clear pended tasks
    finish_datetime = Timex.shift(created_at, days: count)
    delay_secs = Timex.diff(DateTime.utc_now(), finish_datetime, :seconds)

    Logger.info(
      "SplitTest##{split_test.id} with #{inspect(split_test.finish_condition)} is enqueued at #{finish_datetime}"
    )

    Honeydew.async({:maybe_finish_split_test, [id]}, @queue, delay_secs: delay_secs)
  end

  def enqueue_maybe_finish_split_test(_split_test), do: :ok

  #####

  def maybe_finish_split_test(split_test_id) do
    split_test_id
    |> SplitTests.get_split_test()
    |> SplitTests.maybe_finish_split_test()
  end
end
