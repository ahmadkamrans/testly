use Mix.Config

config :testly, ecto_repos: [Testly.Repo], generators: [binary_id: true]

config :testly, Testly.TrackingScript,
  enable_supervisor: false,
  source_script_url: "http://localhost:3001/testly.js",
  bucket: "cdn-localhost.testly.com"

config :testly, Testly.CloudFlare,
  zone_identifier: '',
  auth_token: ''

config :testly, Testly.Repo,
  migration_timestamps: [type: :utc_datetime, inserted_at: :created_at],
  migration_primary_key: [type: :uuid]

config :testly, Testly.Accounts,
  impl: Testly.Accounts,
  reset_password_token_expiration_hours: 24

config :testly, Testly.SessionRecordingsHandler,
  impl: Testly.SessionRecordingsHandler,
  enable_supervisor: true

config :testly, Testly.Projects, impl: Testly.Projects
config :testly, Testly.SessionRecordings, impl: Testly.SessionRecordings
config :testly, Testly.SplitTests, impl: Testly.SplitTests

config :testly, Testly.Authenticator.Session, remember_me_live_days: 30

config :testly, :session_cookie_domain, "localhost"

config :testly, Testly.SmartProxy, proxy_url: "http://localhost:4003/proxy/:recording_id/:url"

config :testly, Testly.SplitTests.VariationReportDbDumper, enabled: true

config :testly, Testly.SessionRecordings.Cleaner, enabled: true

config :testly, Testly.Heatmaps.ViewsCleaner, enabled: true

config :joken,
  default_signer: [
    signer_alg: "HS256",
    key_octet: "test"
  ]

import_config "#{Mix.env()}.exs"
