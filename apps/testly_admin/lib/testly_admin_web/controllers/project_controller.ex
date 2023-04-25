defmodule TestlyAdminWeb.ProjectController do
  use TestlyAdminWeb, :controller

  alias Testly.Projects
  # alias Testly.Projects.Project

  def index(conn, params) do
    case Projects.paginate_projects(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Projects. #{inspect(error)}")
        |> redirect(to: Routes.project_path(conn, :index))
    end
  end

  # def new(conn, _params) do
  #   changeset = Projects.change_project(%Project{})
  #   render(conn, "new.html", changeset: changeset)
  # end

  # def create(conn, %{"project" => project_params}) do
  #   case Projects.create_project(project_params) do
  #     {:ok, project} ->
  #       conn
  #       |> put_flash(:info, "Project created successfully.")
  #       |> redirect(to: Routes.project_path(conn, :show, project))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "new.html", changeset: changeset)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    changeset = Projects.change_project(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    Projects.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
