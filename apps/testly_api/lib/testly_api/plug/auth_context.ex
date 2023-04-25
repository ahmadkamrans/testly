defmodule TestlyAPI.Plug.AuthContext do
  @behaviour Plug

  alias Testly.Accounts
  alias Testly.Projects

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _) do
    build_context(conn, conn.assigns.current_account_user)
  end

  @spec build_context(Plug.Conn.t(), Accounts.User.t() | nil) :: Plug.Conn.t()
  def build_context(conn, nil) do
    Absinthe.Plug.put_options(conn,
      context: %{
        current_account_user: nil,
        current_project_user: nil
      }
    )
  end

  def build_context(conn, %Accounts.User{id: user_id} = user) do
    %Projects.User{} = projects_user = Projects.get_user(user_id)

    Absinthe.Plug.put_options(conn,
      context: %{
        current_account_user: user,
        current_project_user: projects_user
      }
    )
  end
end
