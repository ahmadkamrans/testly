defmodule TestlySmartProxyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :testly_smart_proxy_web
  use Appsignal.Phoenix

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.Head

  plug(CORSPlug,
    origin: [
      "http://localhost:3000",
      "http://localhost:8080",
      "https://dashboard-stage.testly.com",
      "https://dashboard.testly.com"
    ]
  )

  plug TestlySmartProxyWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
