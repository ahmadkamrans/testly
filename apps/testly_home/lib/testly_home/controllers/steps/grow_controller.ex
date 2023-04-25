defmodule TestlyHome.Steps.GrowController do
  use TestlyHome, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    render(conn, "index.html", header_for_features: true)
  end
end
