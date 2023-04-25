defmodule Testly.TrackingScript.CollectorTest do
  use ExUnit.Case, async: true

  alias Testly.TrackingScript.{Collector}

  test "works" do
    {:ok, pid} = Collector.start_link([], name: :collector_test)

    Collector.upload(pid, [{"id", "body"}])

    assert [{"id", "body"}] = GenStage.stream([{pid, max_demand: 10}]) |> Enum.take(1)
  end
end
