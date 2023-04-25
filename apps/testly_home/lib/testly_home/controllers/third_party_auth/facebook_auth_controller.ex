defmodule TestlyHome.ThirdPartyAuth.FacebookAuthController do
  use TestlyHome, :controller
  alias Testly.Accounts
  alias Testly.Accounts.User
  alias Testly.Authenticator.Session
  alias Testly.Encryptor
  require Logger

  plug(Ueberauth)

  @spec request(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def request(conn, _params) do
    conn
  end

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    Logger.error("Failed to facebook login: #{inspect(fails)}")

    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    facebook_user =
      auth
      |> Map.fetch!(:extra)
      |> Map.fetch!(:raw_info)
      |> Map.fetch!(:user)

    case Accounts.get_user_by_facebook_identifier(facebook_user["id"]) do
      %User{} = user ->
        conn
        |> Session.sign_in(user.id, false)
        |> redirect_to_relevant_project(user)

      nil ->
        auth_data =
          %{
            third_party_type: "facebook",
            facebook_identifier: facebook_user["id"],
            email: facebook_user["email"],
            full_name: facebook_user["name"]
          }
          |> Jason.encode!()
          |> Encryptor.encrypt(encryption_key())
          |> Base.encode64()

        conn
        |> redirect(to: Routes.third_party_user_path(conn, :new, auth_data: auth_data))
    end
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
