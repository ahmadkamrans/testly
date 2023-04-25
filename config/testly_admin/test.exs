use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :testly_admin, TestlyAdminWeb.Endpoint,
  http: [port: 4002],
  server: false

# Configure your database
config :testly_admin, TestlyAdmin.Repo,
  username: "postgres",
  password: "postgres",
  database: "testly_admin_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
