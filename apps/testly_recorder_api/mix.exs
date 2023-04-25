defmodule TestlyRecorderAPI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :testly_recorder_api,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TestlyRecorderAPI.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.2"},
      {:httpotion, "~> 3.1.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", override: true},
      {:cors_plug, "~> 1.5.2"},
      {:mox, "~> 0.5.0", only: :test},
      {:proper_case, "~> 1.3.0"},
      {:remote_ip, "~> 0.1.0"}
    ]
  end
end
