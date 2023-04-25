defmodule TestlyHome.User.PasswordController do
  use TestlyHome, :controller

  alias Testly.Accounts
  alias Testly.Accounts.{User, ResetPasswordForm, ResetPasswordTokenForm}

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Accounts.change_reset_password_token_form(%ResetPasswordTokenForm{})
    render(conn, "new.html", changeset: changeset, header_inverted: true)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"reset_password_token_form" => form_attrs}) do
    case Accounts.reset_password_token(form_attrs) do
      {:ok, user} ->
        render(conn, "new.html", header_inverted: true, success: true, email: user.email)

      {:error, ch} ->
        render(conn, "new.html",
          changeset: %{ch | action: :validation_errors},
          header_inverted: true
        )
    end
  end

  @spec edit(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def edit(conn, %{"token" => token}) do
    case Accounts.get_unexpired_user_by_reset_password_token(token) do
      %User{} ->
        changeset = Accounts.change_reset_password_form(%ResetPasswordForm{})
        render(conn, "edit.html", changeset: changeset, header_inverted: true)

      nil ->
        redirect(conn, to: "/")
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"token" => token, "reset_password_form" => form_attrs}) do
    user = Accounts.get_unexpired_user_by_reset_password_token(token)

    case Accounts.reset_password(user, form_attrs) do
      {:ok, _user} ->
        render(conn, "edit.html", header_inverted: true, success: true)

      {:error, ch} ->
        render(conn, "edit.html",
          changeset: %{ch | action: :validation_errors},
          header_inverted: true
        )
    end
  end
end
