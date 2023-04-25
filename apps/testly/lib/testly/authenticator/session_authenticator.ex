defmodule Testly.Authenticator.Session do
  import Plug.Conn

  @moduledoc """
  We use session_alive cookie bacause we can't set dynamically the
  living time of cookie. We also provides 2 plugs:
  1) InvalidateSessionPlug - remember_me=false(session durign browser is opened) support
  2) FetchUserPlug - fetch user from Accounts context
  """

  @spec sign_in(Plug.Conn.t(), String.t(), boolean()) :: Plug.Conn.t()
  def sign_in(conn, user_id, remember_me) do
    conn
    |> put_session("user_id", user_id)
    |> put_resp_cookie("session_alive", "true",
      max_age: if(remember_me, do: remember_me_live_days() * 60 * 60, else: nil),
      domain: root_domain()
    )
  end

  @spec sign_out(Plug.Conn.t()) :: Plug.Conn.t()
  def sign_out(conn) do
    conn
    |> delete_session("user_id")
    |> delete_resp_cookie("session_alive")
  end

  defp root_domain do
    Application.fetch_env!(:testly, :session_cookie_domain)
  end

  defp remember_me_live_days do
    Keyword.fetch!(Application.fetch_env!(:testly, Testly.Authenticator.Session), :remember_me_live_days)
  end
end
