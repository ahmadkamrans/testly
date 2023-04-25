defmodule TestlyMailer.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      # supervisor(TestlyMailerWeb.Endpoint, [])
      # Start your own worker by calling: TestlyMailer.Worker.start_link(arg1, arg2, arg3)
      # worker(TestlyMailer.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestlyMailer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
