# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_api,
  namespace: TestlyAPI

# Configures the endpoint
config :testly_api, TestlyAPI.Endpoint,
  url: [host: "localhost"],
  # NOTE: token is the same as for testly_web
  secret_key_base: "sNRijWIwrjxIiubgpYwjmVIpCtQUKOp05bTa7TFbiRJbMT8Dhfkus5JhEbfVWMGL",
  render_errors: [view: TestlyAPI.ErrorView, accepts: ~w(json)],
  pubsub_server: TestlyAPI.PubSub,
  check_origin: false,
  live_view: [signing_salt: "Fg-dx4h93Iin0QGB"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
