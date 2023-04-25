defmodule TestlySmartProxyWeb.ProxyController do
  use TestlySmartProxyWeb, :controller

  alias TestlySmartProxyWeb.ConnProxier

  def root(conn, _params) do
    json(conn, %{status: :ok})
  end

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"recording_id" => recording_id, "url" => url}) do
    ConnProxier.proxy(
      conn,
      recording_id: recording_id,
      current_url: url
    )
  end
end
