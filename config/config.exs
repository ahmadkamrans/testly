# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "*/config.exs"

config :exq,
  name: Exq,
  namespace: "exq",
  queues: [{"default", 10_000}, {"database", 10}],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 10,
  shutdown_timeout: 5000,
  dead_max_jobs: 10_000

config :geolix, init: {GeolixInit, :init}

config :ua_inspector,
  init: {UAInspectorInit, :init},
  skip_download_readme: true

config :ref_inspector,
  init: {RefInspectorInit, :init},
  skip_download_readme: true

config :phoenix, :json_library, Jason
config :phoenix, :format_encoders, json: ProperCase.JSONEncoder.CamelCase

config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, [profile_fields: "id,name,email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "279076512818921",
  client_secret: "64fb26828fbfe9b58a759f34ceeb8500"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :libcluster,
  topologies: [
    testly: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]

config :arc,
  storage: Arc.Storage.Local,
  asset_host: "http://localhost:4000"

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
