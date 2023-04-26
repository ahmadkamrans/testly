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
  ssl: false,
  pool_size: pool_size,
  timeout: 60_000,
  pool_timeout: 60_000

config :testly, Testly.SmartProxy, proxy_url: "${TESTLY_SMART_PROXY_URL}"

config :testly, :session_cookie_domain, ".testly.com"

config :testly, Testly.TrackingScript,
  enable_supervisor: true,
  source_script_url: "${TRACKING_SCRIPT_URL}",
  bucket: "${TRACKING_SCRIPT_BUCKET}"

config :testly, Testly.CloudFlare,
  zone_identifier: "${TESTLY_CLOUDFLARE_ZONE_IDENTIFIER}",
  auth_token: "${TESTLY_CLOUDFLARE_AUTH_TOKEN}"

config :joken,
  default_signer: [
    signer_alg: "HS256",
    key_octet: "${TESTLY_JWT_SIGN_KEY}"
  ]
config :testly, Testly.Endpoint, server: true, url: [host: "testly@localhost"] 