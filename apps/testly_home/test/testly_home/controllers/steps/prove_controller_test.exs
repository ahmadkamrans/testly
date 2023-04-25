defmodule TestlyHome.Steps.ProveControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /steps/prove/ab_split_testing", %{conn: conn} do
    conn = get(conn, "/steps/prove/ab_split_testing")
    assert html_response(conn, 200) =~ "Run Unlimited A/B Split Tests"
  end

  test "GET /steps/prove/idea_lab", %{conn: conn} do
    conn = get(conn, "/steps/prove/idea_lab")
    assert html_response(conn, 200) =~ "Take The Ideas & Integrate Them Into Your Business"
  end

  test "GET /steps/prove/shared_tests", %{conn: conn} do
    conn = get(conn, "/steps/prove/shared_tests")
    assert html_response(conn, 200) =~ "Learn Which Strategies Are Working For Others"
  end
end
