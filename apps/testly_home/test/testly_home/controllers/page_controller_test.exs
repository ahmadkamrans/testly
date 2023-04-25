defmodule TestlyHome.PageControllerTest do
  use TestlyHome.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Sign in"
  end
end
