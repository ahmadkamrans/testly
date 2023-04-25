defmodule TestlyHome.EnsureAuthenticated do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  alias Plug.Conn
  alias TestlyHome.Router.Helpers, as: Routes

  @spec init(any()) :: any()
  def init(default), do: default

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(%Conn{} = conn, _default) do
    if conn.assigns.current_user == nil do
      conn
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    else
      conn
    end
  end
end
