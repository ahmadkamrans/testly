defmodule Testly.Authenticator.InvalidateSessionPlugTest do
  use Testly.DataCase, async: true
  use Plug.Test

  alias Plug.Conn
  alias Testly.Authenticator.InvalidateSessionPlug

  test "with session_alive" do
    conn =
      conn(:get, "/")
      |> init_test_session(%{"user_id" => "123"})
      |> put_req_cookie("session_alive", "true")
      |> Conn.fetch_cookies()
      |> InvalidateSessionPlug.call(%{})

    assert %{private: %{plug_session: %{"user_id" => "123"}}} = conn
  end

  test "without session_alive" do
    conn =
      conn(:get, "/")
      |> init_test_session(%{"user_id" => "123"})
      |> Conn.fetch_cookies()
      |> InvalidateSessionPlug.call(%{})

    assert conn.private.plug_session == %{}
  end
end
