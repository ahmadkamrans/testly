defmodule TestlyAdminWeb.TestIdeaCategoryController do
  use TestlyAdminWeb, :controller

  alias Testly.IdeaLab
  alias Testly.IdeaLab.Category

  def index(conn, params) do
    case IdeaLab.paginate_categories(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Categories. #{inspect(error)}")
        |> redirect(to: Routes.project_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = IdeaLab.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    category = IdeaLab.get_category(id)
    render(conn, "show.html", category: category)
  end

  def create(conn, %{"category" => category_params}) do
    case IdeaLab.create_category(category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: Routes.test_idea_category_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    category = IdeaLab.get_category(id)
    changeset = IdeaLab.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = IdeaLab.get_category(id)

    case IdeaLab.update_category(category, category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: Routes.test_idea_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = IdeaLab.get_category(id)
    {:ok, _category} = IdeaLab.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: Routes.test_idea_category_path(conn, :index))
  end
end
