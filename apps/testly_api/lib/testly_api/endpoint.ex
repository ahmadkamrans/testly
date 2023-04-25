defmodule TestlyAPI.Endpoint do
  use Phoenix.Endpoint, otp_app: :testly_api
  use Appsignal.Phoenix

  plug(AppsignalAbsinthePlug)
  plug(Plug.Logger)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.

  # NOTE: it is the same key as for testly_web
  plug(Plug.Session,
    store: :cookie,
    key: "_testly_web_key",
    signing_salt: "/tbRx69V",
    max_age: 60 * 60 * 24 * 30,
    domain: Application.fetch_env!(:testly, :session_cookie_domain)
  )

  # TODO: We need it
  # plug Plug.CSRFProtection

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(CORSPlug,
    origin: [
      "http://localhost:3000",
      "https://dashboard-stage.testly.com",
      "https://dashboard.testly.com"
    ]
  )

  plug(TestlyAPI.Router)

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
