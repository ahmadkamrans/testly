defmodule Testly.TrackingScript.SourceCacherTest do
  use ExUnit.Case, async: true

  alias Testly.TrackingScript.SourceCacher

  test "when download works" do
    download = fn -> {:ok, "body"} end
    {:ok, pid} = SourceCacher.start_link([download: download], name: :source_cacher_test)

    assert SourceCacher.get_script(pid) === "body"
  end

  test "when download fails" do
    download = fn -> :error end
    assert {:error, _reason} = SourceCacher.start_link([download: download], name: :source_cacher_test)
  end
end
