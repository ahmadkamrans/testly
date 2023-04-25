defmodule TestlyHome.ScriptRedirectorTest do
  use TestlyHome.ConnCase, async: true

  test "redirect on old script", %{conn: conn} do
    conn = get(conn, "/tracking/1023/script.js?on=http://localhost:4000/")

    assert redirected_to(conn, 302) == "https://old.testly.com/tracking/1023/script.js?on=http://localhost:4000/"
  end
end
