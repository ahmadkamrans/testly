defmodule Testly.AuthenticateHelper do
  def auth_user(conn, user_id) do
    conn
    |> Plug.Test.init_test_session(user_id: user_id)
    |> Plug.Test.put_req_cookie("session_alive", "true")
  end
end
