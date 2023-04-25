defmodule TestlyAPI.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      alias TestlyAPI.Router.Helpers, as: Routes
      import Testly.AuthenticateHelper

      # The default endpoint for testing
      @endpoint TestlyAPI.Endpoint
    end
  end

  setup tags do
    alias Phoenix.ConnTest
    alias Ecto.Adapters.SQL.Sandbox
    alias Testly.Repo

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, conn: ConnTest.build_conn()}
  end
end
