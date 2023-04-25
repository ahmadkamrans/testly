defmodule TestlyAdminWeb.SessionController do
  use TestlyAdminWeb, :controller

  alias Testly.Accounts.SignInForm
  alias Testly.Accounts
  alias Testly.Authenticator.Session
  plug :put_layout, false

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Accounts.change_sign_in_form(%SignInForm{})
    render(conn, "new.html", changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"sign_in_form" => params}) do
    case Accounts.sign_in_admin(params) do
      {:ok, form} ->
        user = Accounts.get_user_by_email(form.email)

        conn
        |> Session.sign_in(user.id, form.remember_me)
        |> redirect(to: "/")

      {:error, ch} ->
        render(conn, "new.html",
          changeset: %{ch | action: :validation_errors},
          header_inverted: true
        )
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> Session.sign_out()
    |> redirect(to: "/auth/signin")
  end
end
