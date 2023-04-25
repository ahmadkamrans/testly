defmodule TestlyAPI.Plug.AuthContext do
  @behaviour Plug

  alias Testly.Accounts.{User}

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @spec build_context(Plug.Conn.t()) :: Plug.Conn.t()
  def build_context(conn) do
    case conn.assigns.current_user do
      %User{} = user -> %{current_user: user}
      _ -> %{}
    end
  end
end
