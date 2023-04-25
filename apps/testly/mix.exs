defmodule Testly.Mixfile do
  use Mix.Project

  def project do
    [
      app: :testly,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Testly.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/tasks"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:testly_mailer, in_umbrella: true},
      {:nimble_csv, "~> 0.3"},
      {:arc_ecto, "~> 0.11.1"},
      {:scrivener_ecto, "~> 2.0"},
      {:proper_case, "~> 1.3.0"},
      {:libcluster, "~> 3.0"},
      {:ex_aws, "~> 2.1", override: true},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:ex_aws_s3, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:ecto_enum, "~> 1.0"},
      {:exq, "~> 0.13"},
      {:bcrypt_elixir, "~> 1.1"},
      {:comeonin, "~> 4.1"},
      {:timex, "~> 3.1"},
      {:geolix, "~> 0.17"},
      {:ua_inspector, "~> 0.18"},
      {:ref_inspector, "~> 0.20"},
      {:httpotion, "~> 3.1.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:gen_stage, "~> 0.14.1"},
      {:paginator, "~> 0.6"},
      {:joken, "~> 2.0"},
      {:mox, "~> 0.5.0", only: :test},
      # Because of https://github.com/cmullaparthi/ibrowse/issues/162
      {:ibrowse, github: "cmullaparthi/ibrowse", override: true},
      {:faker, "~> 0.10", only: :test},
      {:ex_machina, github: "thoughtbot/ex_machina", only: :test},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
