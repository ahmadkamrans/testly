# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :testly_mailer,
  namespace: TestlyMailer

config :testly_mailer, :external_urls,
  support_url: "http://support.testly.com",
  reset_password_form_url: "http://localhost:4000/user/password/edit",
  login_url: "http://localhost:4000/sessions/new"

config :testly_mailer, TestlyMailer.Email, support_from: {"Team Testly", "support@testly.com"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
