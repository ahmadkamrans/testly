defmodule TestlyHome.ProjectController do
  use TestlyHome, :controller

  alias Testly.Projects
  alias Testly.Projects.Project

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Projects.change_project(%Project{})
    render(conn, "new.html", changeset: changeset, header_inverted: true)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"project" => project_params}) do
    user = conn.assigns.current_account_user

    case Projects.create_project(user.id, project_params) do
      {:ok, project} ->
        redirect(conn, external: project_setup_url(project.id))

      {:error, ch} ->
        render(conn, "new.html", changeset: %{ch | action: :validation_errors}, header_inverted: true)
    end
  end
end
