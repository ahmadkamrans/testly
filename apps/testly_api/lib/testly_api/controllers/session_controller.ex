defmodule TestlyAPI.SessionController do
  use TestlyAPI, :controller

  alias Testly.Authenticator.Session

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> Session.sign_out()
    |> send_resp(200, "")
  end
end
