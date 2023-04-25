defmodule TestlyAdminWeb.TestIdeaController do
  use TestlyAdminWeb, :controller

  alias Testly.IdeaLab
  alias Testly.IdeaLab.Idea

  def index(conn, params) do
    case IdeaLab.paginate_ideas(params) do
      {:ok, assigns} ->
        render(conn, "index.html", Map.merge(assigns, %{categories: IdeaLab.get_categories()}))

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Ideas. #{inspect(error)}")
        |> redirect(to: Routes.test_idea_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = IdeaLab.change_idea(%Idea{})
    render(conn, "new.html", changeset: changeset, categories: IdeaLab.get_categories())
  end

  def create(conn, %{"idea" => idea_params}) do
    case IdeaLab.create_idea(idea_params) do
      {:ok, _idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: Routes.test_idea_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, categories: IdeaLab.get_categories())
    end
  end

  def show(conn, %{"id" => id}) do
    idea = IdeaLab.get_idea(id)
    render(conn, "show.html", idea: idea)
  end

  def edit(conn, %{"id" => id}) do
    idea = IdeaLab.get_idea(id)
    changeset = IdeaLab.change_idea(idea)

    render(conn, "edit.html",
      idea: idea,
      changeset: changeset,
      categories: IdeaLab.get_categories()
    )
  end

  def update(conn, %{"id" => id, "idea" => idea_params}) do
    idea = IdeaLab.get_idea(id)

    case IdeaLab.update_idea(idea, idea_params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: Routes.test_idea_path(conn, :show, idea))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          idea: idea,
          changeset: changeset,
          categories: IdeaLab.get_categories()
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    idea = IdeaLab.get_idea(id)
    {:ok, _idea} = IdeaLab.delete_idea(idea)

    conn
    |> put_flash(:info, "Idea deleted successfully.")
    |> redirect(to: Routes.test_idea_path(conn, :index))
  end
end
