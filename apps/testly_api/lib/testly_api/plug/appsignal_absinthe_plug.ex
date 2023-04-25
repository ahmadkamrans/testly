defmodule AppsignalAbsinthePlug do
  alias Appsignal.Transaction

  def init(_), do: nil

  # Change me to your route's path
  @path "/graphql"
  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Transaction.set_action("POST " <> @path)
    conn
  end

  def call(conn, _) do
    conn
  end
end
