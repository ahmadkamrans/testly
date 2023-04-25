defmodule TestlyHome.LegalControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /legal", %{conn: conn} do
    conn = get(conn, "/legal")
    assert html_response(conn, 200) =~ "testly.com is an registered trademark of Bryxen"
  end

  test "GET /legal/policy", %{conn: conn} do
    conn = get(conn, "/legal/policy")
    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  test "GET /legal/terms", %{conn: conn} do
    conn = get(conn, "/legal/terms")
    assert html_response(conn, 200) =~ "Terms Of Use"
  end

  test "GET /legal/disclaimer", %{conn: conn} do
    conn = get(conn, "/legal/disclaimer")
    assert html_response(conn, 200) =~ "Earnings Disclaimer"
  end

  test "GET /legal/agreement", %{conn: conn} do
    conn = get(conn, "/legal/agreement")
    assert html_response(conn, 200) =~ "Affiliate Agreement"
  end
end
