defmodule Testly.Authenticator.InvalidateSessionPlug do
  import Plug.Conn

  alias Plug.Conn
  alias Testly.Authenticator.Session

  @spec init(any()) :: any()
  def init(default), do: default

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(%Conn{} = conn, _default) do
    if conn.req_cookies["session_alive"] == "true" do
      conn
    else
      if get_session(conn, "user_id") !== "" do
        Session.sign_out(conn)
      else
        conn
      end
    end
  end
end
