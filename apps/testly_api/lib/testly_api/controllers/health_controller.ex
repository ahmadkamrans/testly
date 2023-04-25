defmodule TestlyAPI.HealthController do
  use TestlyAPI, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: :ok})
  end
end
