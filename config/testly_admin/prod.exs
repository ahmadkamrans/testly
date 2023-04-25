use Mix.Config

config :testly_admin, TestlyAdminWeb.Endpoint,
  load_from_system_env: false,
  http: [port: 4004, compress: true],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true
