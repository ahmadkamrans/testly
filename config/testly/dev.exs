use Mix.Config

config :testly, Testly.SplitTests.VariationReportDbDumper, enabled: false
config :testly, Testly.SessionRecordings.Cleaner, enabled: true
config :testly, Testly.Heatmaps.ViewsCleaner, enabled: true

# Configure your database
config :testly, Testly.Repo,
  username: "postgres",
  password: "postgres",
  database: "testly_dev",
  hostname: "localhost",
  pool_size: 10
config :testly, Testly.Endpoint, server: true, url: [host: "testly@localhost"] 