defmodule TestlyHome.SessionControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /sessions/new", %{conn: conn} do
    conn = get(conn, "/sessions/new")
    assert html_response(conn, 200) =~ "Login"
  end
end
