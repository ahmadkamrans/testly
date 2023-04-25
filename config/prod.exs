use Mix.Config

config :exq,
  url: {:system, "TESTLY_REDIS_URL"}

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "${TESTLY_HOME_FACEBOOK_CLIENT_ID}",
  client_secret: "${TESTLY_HOME_FACEBOOK_CLIENT_SECRET}"

# Do not print debug messages in production
config :logger,
       :console,
       format: "$metadata[$level] $message\n",
       level: :info,
       metadata: [:mfa, :crash_reason, :request_id, :user_id]

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
        query: "${TESTLY_LIBCLUSTER_QUERY}",
        node_basename: "testly"
      ]
    ]
  ]

config :arc,
  storage: Arc.Storage.S3,
  bucket: {:system, "S3_BUCKET"},
  asset_host: {:system, "UPLOAD_HOST"}
