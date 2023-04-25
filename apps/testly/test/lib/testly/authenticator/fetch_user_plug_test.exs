defmodule Testly.Authenticator.FetchUserPlugTest do
  use Testly.DataCase, async: true
  use Plug.Test
  import Testly.DataFactory

  alias Plug.Conn
  alias Testly.Authenticator.FetchUserPlug

  test "user found" do
    user = insert(:user)

    conn =
      conn(:get, "/")
      |> init_test_session(%{"user_id" => user.id})
      |> Conn.fetch_cookies()
      |> FetchUserPlug.call(%{})

    assert conn.assigns.current_account_user == user
  end

  test "when user not found" do
    conn =
      conn(:get, "/")
      |> init_test_session(%{"user_id" => "98e01a0f-f7fc-4e02-a697-dd88b62d16b4"})
      |> Conn.fetch_cookies()
      |> FetchUserPlug.call(%{})

    assert conn.private.plug_session == %{}
    assert conn.assigns.current_account_user == nil
  end

  test "when user_id not set" do
    conn =
      conn(:get, "/")
      |> init_test_session(%{})
      |> Conn.fetch_cookies()
      |> FetchUserPlug.call(%{})

    assert conn.assigns.current_account_user == nil
  end
end
