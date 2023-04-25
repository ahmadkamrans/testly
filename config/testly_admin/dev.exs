use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :testly_admin, TestlyAdminWeb.Endpoint,
  http: [port: 4004],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../apps/testly_admin/assets", __DIR__)
    ]
  ]

config :testly_admin, TestlyAdminWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/testly_admin_web/views/.*(ex)$},
      ~r{lib/testly_admin_web/templates/.*(eex)$}
    ]
  ]
