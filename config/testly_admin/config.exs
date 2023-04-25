# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# config :testly_admin,
#   ecto_repos: [Testly.Repo]

# Configures the endpoint
config :testly_admin, TestlyAdminWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2MrP7jaAYQZjspyZ6iz2f/5pBSsInT82VsxB0cqIqD3EDxo5/mtLzOfFQmv4PU0b",
  render_errors: [view: TestlyAdminWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TestlyAdmin.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
