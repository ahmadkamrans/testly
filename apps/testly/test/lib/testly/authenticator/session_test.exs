defmodule Testly.Authenticator.SessionTest do
  use Testly.DataCase, async: true
  use Plug.Test

  alias Testly.Authenticator.Session

  describe "#sign_in" do
    test "with session_alive" do
      conn =
        conn(:get, "/")
        |> init_test_session(%{})
        |> Session.sign_in("123", true)

      max_age = 60 * 60 * 30

      assert %{
               resp_cookies: %{"session_alive" => %{max_age: ^max_age, value: "true"}},
               private: %{plug_session: %{"user_id" => "123"}}
             } = conn
    end

    test "without session_alive" do
      conn =
        conn(:get, "/")
        |> init_test_session(%{})
        |> Session.sign_in("123", false)

      assert %{
               resp_cookies: %{"session_alive" => %{max_age: nil, value: "true"}},
               private: %{plug_session: %{"user_id" => "123"}}
             } = conn
    end
  end
end
