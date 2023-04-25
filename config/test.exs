use Mix.Config

config :exq,
  namespace: "test",
  scheduler_enable: false

# Print only warnings and errors during test
config :logger, level: :warn
