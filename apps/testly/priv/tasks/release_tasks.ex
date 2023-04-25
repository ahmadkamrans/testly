defmodule Testly.ReleaseTasks do
  @moduledoc false

  @compile :nowarn

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql,
    :ua_inspector,
    :ref_inspector
  ]

  @repos Application.get_env(:testly, :ecto_repos, [])

  def migrate(_argv) do
    start_services()
    run_migrations()
    stop_services()
  end

  def seed(_argv) do
    start_services()
    run_seeds()
    stop_services()
  end

  def prepare(_argv) do
    start_services()
    # download_dbs()
    run_migrations()
    # run_seeds()
    stop_services()
  end

  # defp download_dbs do
  #   IO.puts("Download UAInspector data")
  #   UAInspector.Downloader.download()
  #   IO.puts("Download RefInspector data")
  #   RefInspector.Downloader.download()
  # end

  defp start_services do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for app
    IO.puts("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end

  defp stop_services do
    IO.puts("Success!")
    :init.stop()
  end

  # defp create_database do
  #   IO.puts("Creating the database if needed...")
  #   Enum.each(@repos, & &1.__adapter__.storage_up(&1.config))
  # end

  defp run_migrations do
    Enum.each(@repos, &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp run_seeds do
    Enum.each(@repos, &run_seeds_for/1)
  end

  defp run_seeds_for(repo) do
    # Run the seed script if it exists
    seed_script = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script..")
      Code.eval_file(seed_script)
    end
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
