defmodule TestlySmartProxyWeb.HealthController do
  use TestlySmartProxyWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: :ok})
  end
end
