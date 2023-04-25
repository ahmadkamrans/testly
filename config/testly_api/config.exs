# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_api,
  namespace: TestlyApi

# Configures the endpoint
config :testly_api, TestlyAPI.Endpoint,
  url: [host: "localhost"],
  # NOTE: token is the same as for testly_web
  secret_key_base: "sNRijWIwrjxIiubgpYwjmVIpCtQUKOp05bTa7TFbiRJbMT8Dhfkus5JhEbfVWMGL",
  render_errors: [view: TestlyAPI.ErrorView, accepts: ~w(json)],
  pubsub: [name: TestlyApi.PubSub, adapter: Phoenix.PubSub.PG2],
  check_origin: false,
  instrumenters: [Appsignal.Phoenix.Instrumenter]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
