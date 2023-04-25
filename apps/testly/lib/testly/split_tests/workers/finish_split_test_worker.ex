defmodule Testly.SplitTests.FinishSplitTestWorker do
  alias Testly.SplitTests

  @spec enqueue(String.t(), DateTime.t()) :: :ok
  def enqueue(split_test_id, at) do
    Exq.enqueue_at(Exq, "default", at, __MODULE__, [split_test_id])
    :ok
  end

  def perform(split_test_id) do
    SplitTests.get_split_test(split_test_id)
    |> SplitTests.maybe_finish_split_test()
  end
end
