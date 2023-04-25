defmodule TestlyAPI.EnsureAdmin do
  import Plug.Conn

  alias Plug.Conn

  @spec init(any()) :: any()
  def init(default), do: default

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(%Conn{} = conn, _default) do
    if conn.assigns.current_account_user == nil || !conn.assigns.current_account_user.is_admin do
      conn
      |> put_status(:not_found)
      |> halt()
    else
      conn
    end
  end
end
