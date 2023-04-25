defmodule TestlyHome.PasswordControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /user/password/new", %{conn: conn} do
    conn = get(conn, "/user/password/new")
    assert html_response(conn, 200) =~ "Email password reset instruction"
  end

  # TODO: Mock?
  # test "GET /user/password/edit", %{conn: conn} do
  #   conn = get(conn, "/user/password/edit", %{token: "test"})
  #   assert html_response(conn, 200) =~ "Change your password"
  # end
end
