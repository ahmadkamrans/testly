use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :testly_recorder_api, TestlyRecorderAPI.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
