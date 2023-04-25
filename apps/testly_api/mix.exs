defmodule TestlyAPI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :testly_api,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TestlyAPI.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:testly, in_umbrella: true},
      {:phoenix, "~> 1.5"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.2"},
      {:absinthe, "1.5.0"},
      {:absinthe_plug, "~> 1.5"},
      {:cors_plug, "~> 1.5.2"},
      {:proper_case, "~> 1.3.0"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      # TODO: change kronky to official when https://github.com/Ethelo/kronky/pull/5 will be merged
      {:kronky, github: "mirego/kronky"}
    ]
  end
end
