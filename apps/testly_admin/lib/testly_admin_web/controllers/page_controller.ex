defmodule TestlyAdminWeb.PageController do
  use TestlyAdminWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
