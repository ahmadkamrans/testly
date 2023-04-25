use Mix.Config

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "${TESTLY_HOME_FACEBOOK_CLIENT_ID}",
  client_secret: "${TESTLY_HOME_FACEBOOK_CLIENT_SECRET}"

# Do not print debug messages in production
config :logger,
       :console,
       format: "$time $metadata[$level] $message\n",
       level: :info,
       metadata: [:application, :pid, :crash_reason, :request_id, :user_id]

config :honeybadger,
  environment_name: :prod,
  api_key: "${COMMON_HONEYBADGER_API_KEY}",
  use_logger: true

config :ex_aws,
  region: "us-east-1"

config :libcluster,
  topologies: [
    testly: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        # Configuration for the provided strategy. Optional.
        polling_interval: 5_000,
        query: "testly-stage-app.local",
        node_basename: "testly"
      ],
      connect: {Testly.HordeClusterConnector, :connect, []}
    ]
  ]

config :appsignal, :config, active: true

config :arc,
  storage: Arc.Storage.S3,
  bucket: {:system, "S3_BUCKET"},
  asset_host: {:system, "UPLOAD_HOST"}
