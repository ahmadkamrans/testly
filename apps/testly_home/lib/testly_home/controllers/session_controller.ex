defmodule TestlyHome.SessionController do
  use TestlyHome, :controller

  alias Testly.Accounts.SignInForm
  alias Testly.Accounts
  alias Testly.Authenticator.Session
  alias Testly.Authenticator.SignInToken

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    render(conn, "new.html",
      changeset: Accounts.change_sign_in_form(%SignInForm{}),
      header_inverted: true
    )
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"sign_in_form" => params}) do
    case Accounts.sign_in_user(params) do
      {:ok, form} ->
        user = Accounts.get_user_by_email(form.email)

        conn
        |> Session.sign_in(user.id, form.remember_me)
        |> redirect_to_relevant_project(user)

      {:error, ch} ->
        render(conn, "new.html",
          changeset: %{ch | action: :validation_errors},
          header_inverted: true
        )
    end
  end

  # It is used by admin panel. It adds ability to sign in to any user from admin panel
  @spec create_by_token(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_by_token(conn, %{"token" => token}) do
    user =
      token
      |> SignInToken.decode!()
      |> Accounts.get_user!()

    conn
    |> Session.sign_in(user.id, false)
    |> redirect_to_relevant_project(user)
  end
end
