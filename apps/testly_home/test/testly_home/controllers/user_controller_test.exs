defmodule TestlyHome.UserControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /users/new", %{conn: conn} do
    conn = get(conn, "/users/new")
    assert html_response(conn, 200) =~ "Create your FREE Testly account"
  end
end
