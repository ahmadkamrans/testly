defmodule TestlyHome.UserController do
  use TestlyHome, :controller
  alias Testly.Accounts.RegistrationForm
  alias Testly.Accounts
  alias Testly.Authenticator.Session

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Accounts.change_registration_form(%RegistrationForm{})
    render(conn, "new.html", changeset: changeset, header_inverted: true)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"registration_form" => form_attrs}) do
    case Accounts.register_user(form_attrs) do
      {:ok, user} ->
        conn
        |> Session.sign_in(user.id, false)
        |> redirect_to_relevant_project(user)

      {:error, ch} ->
        render(conn, "new.html", changeset: %{ch | action: :insert}, header_inverted: true)
    end
  end
end
