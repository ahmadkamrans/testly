use Mix.Config

pool_size =
  case Integer.parse("${DATABASE_POOL_SIZE}") do
    :error -> 20
    {size, _} -> size
  end

# Configure your database
config :testly, Testly.Repo,
  url: "${DATABASE_URL}",
  database: "",
  ssl: true,
  pool_size: pool_size

config :testly, Testly.SmartProxy, proxy_url: "${TESTLY_SMART_PROXY_URL}"

config :testly, :session_cookie_domain, ".testly.com"

config :testly, Testly.TrackingScript,
  enable_supervisor: true,
  source_script_url: "${TRACKING_SCRIPT_URL}",
  bucket: "${TRACKING_SCRIPT_BUCKET}"
