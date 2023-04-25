# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_home,
  namespace: TestlyHome

# Configures the endpoint
config :testly_home, TestlyHome.Endpoint,
  secret_key_base: "sNRijWIwrjxIiubgpYwjmVIpCtQUKOp05bTa7TFbiRJbMT8Dhfkus5JhEbfVWMGL",
  url: [host: "localhost"],
  http: [port: 4000],
  render_errors: [view: TestlyHome.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TestlyHome.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [Appsignal.Phoenix.Instrumenter],
  serve_local_uploads: false

config :testly_home, :external_urls,
  project: "http://localhost:3000/projects/:project_id",
  project_setup: "http://localhost:3000/projects/:project_id/setup",
  knowledgebase: "http://support.testly.com/support/solutions",
  customer_support: "http://support.testly.com",
  blog: "https://blog.testly.com",
  affiliate: "https://affiliates.testly.com",
  testly_old_site: "https://old.testly.com"

config :testly_home, :contacts, support_email: "support@testly.com"

config :testly_home, :encryption_keys, third_party_auth: :base64.decode("fzkQpR82lKq7hH0AoD+/VEvVgLnzfthww95ZZNAG5EU=")

config :testly_home, :honeybadger_js, enabled: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
