defmodule Testly.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  import Testly.DataFactory

  using do
    quote do
      alias Testly.Repo
      alias Ecto.Changeset

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Testly.DataFactory
      import Testly.DataCase
    end
  end

  setup tags do
    alias Ecto.Adapters.SQL.Sandbox
    alias Testly.Repo

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def insert_project(_content) do
    %{
      project: insert(:project)
    }
  end

  def insert_ready_session_recording(_context) do
    project = insert(:project)

    session_recording =
      insert(:session_recording,
        project_id: project.id,
        pages: [
          build(:session_recording_page)
        ]
      )

    page = List.first(session_recording.pages)

    owner_data = [session_recording_id: session_recording.id, page_id: page.id]
    happened_at = DateTime.utc_now()

    events = [
      insert(:page_visited_event_schema, owner_data ++ [happened_at: happened_at]),
      insert(:dom_mutated_event_schema, owner_data ++ [happened_at: Timex.shift(happened_at, seconds: 1)]),
      insert(:scrolled_event_schema, owner_data ++ [happened_at: Timex.shift(happened_at, seconds: 2)]),
      insert(:mouse_clicked_event_schema, owner_data ++ [happened_at: Timex.shift(happened_at, seconds: 3)]),
      insert(:mouse_moved_event_schema, owner_data ++ [happened_at: Timex.shift(happened_at, seconds: 4)]),
      insert(:window_resized_event_schema, owner_data ++ [happened_at: Timex.shift(happened_at, seconds: 5)])
    ]

    %{
      project: project,
      session_recording: session_recording,
      events: events
    }
  end
end
