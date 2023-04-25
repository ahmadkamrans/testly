defmodule TestlyHome.Steps.LearnControllerTest do
  use TestlyHome.ConnCase, async: true

  test "GET /steps/learn/session_recordings", %{conn: conn} do
    conn = get(conn, "/steps/learn/session_recordings")
    assert html_response(conn, 200) =~ "Watch live, visitor session recordings"
  end

  test "GET /steps/learn/heatmaps", %{conn: conn} do
    conn = get(conn, "/steps/learn/heatmaps")

    assert html_response(conn, 200) =~
             "See how they are interacting with your website or specific pages."
  end

  test "GET /steps/learn/feedback_polls", %{conn: conn} do
    conn = get(conn, "/steps/learn/feedback_polls")
    assert html_response(conn, 200) =~ "Create Feedback Widget"
  end
end
