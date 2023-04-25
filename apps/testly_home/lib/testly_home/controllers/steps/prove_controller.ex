defmodule TestlyHome.Steps.ProveController do
  use TestlyHome, :controller

  @spec ab_split_testing(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def ab_split_testing(conn, _params) do
    render(conn, "ab_split_testing.html", header_for_features: true)
  end

  @spec idea_lab(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def idea_lab(conn, _params) do
    render(conn, "idea_lab.html", header_for_features: true)
  end

  @spec shared_tests(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def shared_tests(conn, _params) do
    render(conn, "shared_tests.html", header_for_features: true)
  end
end
