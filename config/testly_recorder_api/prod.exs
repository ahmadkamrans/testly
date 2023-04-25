use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :testly_recorder_api, TestlyRecorderAPI.Endpoint,
  load_from_system_env: false,
  http: [port: 4002, compress: true],
  secret_key_base: "${SECRET_KEY_BASE}",
  url: [host: "example.com", port: 80],
  server: true
