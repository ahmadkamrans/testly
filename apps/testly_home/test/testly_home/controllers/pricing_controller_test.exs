defmodule TestlyHome.PricingControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /pricing", %{conn: conn} do
    conn = get(conn, "/pricing")
    assert html_response(conn, 200) =~ "Simple And Transparent Pricing"
  end
end
