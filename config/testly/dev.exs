use Mix.Config

config :testly, Testly.SplitTests.VariationReportDbDumper, enabled: false
# Configure your database
config :testly, Testly.Repo,
  username: "postgres",
  password: "postgres",
  database: "testly_dev",
  hostname: "localhost",
  pool_size: 10
