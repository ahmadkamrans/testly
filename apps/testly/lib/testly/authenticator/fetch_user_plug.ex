defmodule Testly.Authenticator.FetchUserPlug do
  import Plug.Conn

  alias Plug.Conn
  alias Testly.Accounts
  alias Testly.Authenticator.Session

  @spec init(any()) :: any()
  def init(default), do: default

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(%Conn{} = conn, _default) do
    user_id = get_session(conn, "user_id")

    if user_id && user_id != "" do
      user = Accounts.get_user(user_id)

      if user do
        assign(conn, :current_account_user, user)
      else
        conn
        |> Session.sign_out()
        |> assign(:current_account_user, nil)
      end
    else
      assign(conn, :current_account_user, nil)
    end
  end
end
