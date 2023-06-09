# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"X|1r0OAo!K7X.gvB8IFD(}59hDYOX%*A>9X%cj_ZcWO.c9g2(4n5B):U1RT$d{rq")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"X|1r0OAo!K7X.gvB8IFD(}59hDYOX%*A>9X%cj_ZcWO.c9g2(4n5B):U1RT$d{rq")
  set(vm_args: "rel/vm.args")

  set(
    commands: [
      migrate: "rel/commands/migrate.sh",
      prepare: "rel/commands/prepare.sh",
      seed: "rel/commands/seed.sh"
    ]
  )
end

release :testly do
  set(version: "0.1.0")

  set(
    applications: [
      :runtime_tools,
      testly_home: :permanent,
      testly_api: :permanent,
      testly_recorder_api: :permanent,
      testly_smart_proxy_web: :permanent,
      testly_admin: :permanent
    ]
  )

  set(pre_start_hooks: "rel/hooks/pre_start")
end
