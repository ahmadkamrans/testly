defmodule TestlyHome.Steps.LearnController do
  use TestlyHome, :controller

  @spec session_recordings(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def session_recordings(conn, _params) do
    render(conn, "session_recordings.html", header_for_features: true)
  end

  @spec heatmaps(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def heatmaps(conn, _params) do
    render(conn, "heatmaps.html", header_for_features: true)
  end

  @spec feedback_polls(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def feedback_polls(conn, _params) do
    render(conn, "feedback_polls.html", header_for_features: true)
  end
end
