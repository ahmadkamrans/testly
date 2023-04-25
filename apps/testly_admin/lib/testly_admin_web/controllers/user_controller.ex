defmodule TestlyAdminWeb.UserController do
  use TestlyAdminWeb, :controller

  alias Testly.Accounts
  alias Testly.Accounts.RegistrationForm
  alias Testly.Authenticator.SignInToken

  def new(conn, _params) do
    changeset = Accounts.change_registration_form(%RegistrationForm{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"registration_form" => form_attrs}) do
    case Accounts.register_user(form_attrs, true) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User is created")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, ch} ->
        render(conn, "new.html", changeset: %{ch | action: :insert})
    end
  end

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

    case Accounts.update_user(user, user_params, true) do
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

  def sign_in(conn, %{"user_id" => user_id}) do
    token = SignInToken.encode!(user_id)

    url =
      Application.fetch_env!(:testly_admin, :external_urls)
      |> Keyword.fetch!(:sign_in)

    redirect(
      conn,
      external: "#{url}?#{URI.encode_query(%{token: token})}"
    )
  end

  # def change_password(conn, %{"id" => id, "reset_password_form" => user_params}) do
  # end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    Accounts.delete_user!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
