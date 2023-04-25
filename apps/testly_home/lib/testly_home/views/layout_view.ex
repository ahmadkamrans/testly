defmodule TestlyHome.LayoutView do
  use TestlyHome, :view

  alias Testly.Accounts.User
  alias TestlyHome.ProjectPathHelper

  @honeybadger_enabled Keyword.fetch!(Application.fetch_env!(:testly_home, :honeybadger_js), :enabled)

  @spec current_user(Plug.Conn.t()) :: User.t() | nil
  def current_user(conn) do
    conn.assigns.current_user
  end

  @spec dashboard_link(Plug.Conn.t(), [{:class, any()}, ...], (any() -> any())) :: {:safe, [...]}
  def dashboard_link(conn, [class: class], content) do
    {type, path} = ProjectPathHelper.path_to_relevant_project(conn, current_user(conn))

    link(to: path, class: class) do
      content.(type)
    end
  end

  @spec honeybadger_js_enabled() :: boolean()
  def honeybadger_js_enabled do
    @honeybadger_enabled
  end
end
