defmodule TestlyAdminWeb.UserController do
  use TestlyAdminWeb, :controller

  alias Testly.Accounts

  def index(conn, params) do
    case Accounts.paginate_users(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Projects. #{inspect(error)}")
        |> redirect(to: Routes.project_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    changeset = Accounts.change_user(user)

    render(conn, "edit.html",
      user: user,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          user: user,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    Accounts.delete_user!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
