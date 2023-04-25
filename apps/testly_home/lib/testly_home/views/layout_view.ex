defmodule TestlyHome.LayoutView do
  use TestlyHome, :view

  alias Testly.Accounts.User
  alias TestlyHome.ProjectPathHelper

  @spec current_account_user(Plug.Conn.t()) :: User.t() | nil
  def current_account_user(conn) do
    conn.assigns.current_account_user
  end

  @spec dashboard_link(Plug.Conn.t(), [{:class, any()}, ...], (any() -> any())) :: {:safe, [...]}
  def dashboard_link(conn, [class: class], content) do
    {type, path} = ProjectPathHelper.path_to_relevant_project(conn, current_account_user(conn))

    link(to: path, class: class) do
      content.(type)
    end
  end
end
