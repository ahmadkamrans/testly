use Mix.Config

# Configure your database
config :testly, Testly.Repo,
  username: "postgres",
  password: "postgres",
  database: "testly_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :testly, Testly.SessionRecordingsHandler,
  impl: Testly.SessionRecordingsHandlerMock,
  enable_supervisor: false

config :testly, Testly.Projects, impl: Testly.ProjectsMock
config :testly, Testly.SessionRecordings, impl: Testly.SessionRecordingsMock
config :testly, Testly.SplitTests.VariationReportDbDumper, enabled: false
