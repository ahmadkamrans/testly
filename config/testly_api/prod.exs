use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :testly_api, TestlyAPI.Endpoint,
  load_from_system_env: false,
  http: [port: 4001, compress: true],
  secret_key_base: "2MrP7jaAYQZjspyZ6iz2f/5pBSsInT82VsxB0cqIqD3EDxo5/mtLzOfFQmv4PU0b",
  url: [host: "example.com", port: 80],
  server: true,
  debug_errors: true

config :testly_api, :session, domain: "testly.com"
