# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_smart_proxy_web,
  namespace: TestlySmartProxyWeb

# Configures the endpoint
config :testly_smart_proxy_web, TestlySmartProxyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CB2ZRDdtsxUa6EwJFFJN87iVb//i+337avsVlNx/7wy+HOORuarcL8Lb+G9zCVhj",
  render_errors: [view: TestlySmartProxyWeb.ErrorView, accepts: ~w(json)],
  instrumenters: [Appsignal.Phoenix.Instrumenter]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
