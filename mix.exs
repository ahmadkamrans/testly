defmodule TestlyCore.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],
      docs: [
        main: "Testly",
        ignore_apps: [
          :testly_api,
          :testly_mailer,
          :testly_recorder_api,
          :testly_home
        ],
        groups_for_modules: [
          Accounts: ~r"Testly.Accounts",
          Projects: ~r"Testly.Projects",
          "Session Recordings": ~r"Testly.SessionRecordings"
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:git_hooks, "~> 0.2.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.13.0", override: true},
      {:appsignal, "~> 1.0"}
    ]
  end
end
