defmodule TestlyHome.ThirdPartyAuth.UserController do
  use TestlyHome, :controller

  alias Testly.Authenticator.Session
  alias Testly.Accounts
  alias Testly.Accounts.ThirdPartyRegistrationForm
  alias Testly.Encryptor

  # auth_data is required
  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, params) do
    auth_data =
      params
      |> Map.fetch!("auth_data")
      |> Base.decode64!()
      |> Encryptor.decrypt(encryption_key())
      |> Jason.decode!()

    changeset =
      Accounts.change_registration_form(%ThirdPartyRegistrationForm{
        email: auth_data["email"],
        full_name: auth_data["full_name"]
      })

    render(
      conn,
      "new.html",
      changeset: changeset,
      encrypted_facebook_identifier: encrypt_facebook_identifier(auth_data["facebook_identifier"]),
      header_inverted: true
    )
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"registration_form" => form_attrs}) do
    form_attrs =
      put_in(
        form_attrs["facebook_identifier"],
        decrypt_facebook_identifier(Map.fetch!(form_attrs, "encrypted_facebook_identifier"))
      )

    case Accounts.third_party_register_user(form_attrs) do
      {:ok, user} ->
        conn
        |> Session.sign_in(user.id, false)
        |> redirect_to_relevant_project(user)

      {:error, ch} ->
        render(conn, "new.html",
          changeset: %{ch | action: :validation_errors},
          encrypted_facebook_identifier: form_attrs["encrypted_facebook_identifier"],
          header_inverted: true
        )
    end
  end

  @spec encrypt_facebook_identifier(String.t()) :: String.t()
  defp encrypt_facebook_identifier(identifier) do
    identifier
    |> Encryptor.encrypt(encryption_key())
    |> Base.encode64()
  end

  @spec decrypt_facebook_identifier(String.t()) :: String.t()
  defp decrypt_facebook_identifier(data) do
    data
    |> Base.decode64!()
    |> Encryptor.decrypt(encryption_key())
  end

  def encryption_key do
    :base64.decode(
      Keyword.fetch!(
        Application.fetch_env!(:testly_home, :encryption_keys),
        :third_party_auth
      )
    )
  end
end
