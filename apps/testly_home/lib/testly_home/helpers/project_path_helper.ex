defmodule TestlyHome.ProjectPathHelper do
  alias Phoenix.Controller
  alias Testly.Accounts.User
  alias Testly.Projects.Models.Project
  alias Testly.Projects

  import TestlyHome.ExternalUrlsHelper
  alias TestlyHome.Router.Helpers, as: Routes

  @spec redirect_to_relevant_project(Plug.Conn.t(), User.t()) :: Plug.Conn.t()
  def redirect_to_relevant_project(%Plug.Conn{} = conn, %User{} = user) do
    case gen_path(conn, Projects.get_relevant_project(user.id)) do
      {:new, path} ->
        Controller.redirect(conn, to: path)

      {:exists, path} ->
        Controller.redirect(conn, external: path)
    end
  end

  @spec path_to_relevant_project(Plug.Conn.t(), User.t()) :: {:new, String.t()} | {:exists, String.t()}
  def path_to_relevant_project(%Plug.Conn{} = conn, %User{} = user) do
    gen_path(conn, Projects.get_relevant_project(user.id))
  end

  @spec gen_path(Plug.Conn.t(), Project.t() | nil) :: {:new, String.t()} | {:exists, String.t()}
  defp gen_path(conn, nil) do
    {:new, Routes.project_path(conn, :new)}
  end

  defp gen_path(_conn, project) do
    {:exists, project_url(project.id)}
  end
end
