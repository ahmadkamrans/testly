use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :testly_smart_proxy_web, TestlySmartProxyWeb.Endpoint,
  http: [port: 4003],
  server: false
