defmodule TestlyHome.Steps.GrowControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /steps/grow", %{conn: conn} do
    conn = get(conn, "/steps/grow")
    assert html_response(conn, 200) =~ "When you learn how visitors are browsing"
  end
end
