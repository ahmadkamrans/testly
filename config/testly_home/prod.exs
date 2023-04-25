use Mix.Config

config :testly_home, TestlyHome.Endpoint,
  load_from_system_env: false,
  http: [port: 4000, compress: true],
  secret_key_base: "${SECRET_KEY_BASE}",
  url: [host: "example.com", port: 80],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :testly_home, :encryption_keys, third_party_auth: "${TESTLY_HOME_THIRD_PARTY_ENCRYPTION_KEY}"

config :testly_home, :external_urls,
  project: "${TESTLY_HOME_PROJECT_URL}",
  project_setup: "${TESTLY_HOME_PROJECT_SETUP_URL}"

config :testly_home, :session, domain: "testly.com"
