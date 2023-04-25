# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_recorder_api,
  namespace: TestlyRecorderAPI

# Configures the endpoint
config :testly_recorder_api, TestlyRecorderAPI.Endpoint,
  url: [host: "localhost"],
  http: [port: 4002],
  secret_key_base: "cpK1YT5OKo5p9kudg/XR9Ax86mRl3snmBAY1so8LiumJEsizqYkwxkyE97PfjSGk",
  render_errors: [view: TestlyRecorderAPI.ErrorView, accepts: ~w(json)],
  pubsub: [name: TestlyRecorderAPI.PubSub, adapter: Phoenix.PubSub.PG2],
  check_origin: false,
  instrumenters: [Appsignal.Phoenix.Instrumenter]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config("#{Mix.env()}.exs")
