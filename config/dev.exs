use Mix.Config

config :exq,
  host: "127.0.0.1",
  port: 6379

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :libcluster,
  topologies: [
    testly: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]

# config :git_hooks,
#   verbose: true,
#   hooks: [
#     pre_commit: [
#       mix_tasks: [
#         "format"
#       ]
#     ],
#     pre_push: [
#       verbose: true,
#       mix_tasks: [
#         "compile --warnings-as-errors --force",
#         "credo",
#         "test"
#       ]
#     ]
#   ]
