use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :testly_home, TestlyHome.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  # watchers: [npm: ["run", "watch", cd: Path.expand("../assets", __DIR__)]],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../apps/testly_home/assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/testly_home/views/.*(ex)$},
      ~r{lib/testly_home/templates/.*(eex)$}
    ]
  ],
  serve_local_uploads: true
