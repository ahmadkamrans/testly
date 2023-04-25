defmodule Testly.Goals do
  alias Ecto.Changeset

  alias Testly.{
    Repo,
    Projects,
    SplitTests
  }

  alias Testly.Goals.{
    Goal,
    GoalQuery,
    Conversion
  }

  alias Testly.SplitTests.{
    SplitTest,
    GoalConversionsFinishCondition
  }

  alias Testly.SessionRecordings.{SessionRecording}
  alias Testly.Projects.{Project}

  defmodule Behaviour do
    @callback get_goal(String.t()) :: Goal.t() | nil
    @callback get_goals(Project.t()) :: [Goal.t()]
    @callback get_goals_count(Project.t()) :: integer
    @callback get_split_test_goal_conversions_count(String.t()) :: integer()
    @callback update_goal(Goal.t(), Goal.t(), map()) ::
                {:ok, Goal.goal()} | {:error, Changeset.t()}
    @callback update_goals(SplitTest.t(), [map()]) :: {:ok, :goals} | {:error, [Changeset.t()]}
    @callback delete_goal(Project.t(), Goal.t()) :: {:ok, Goal.t()}
    @callback convert_goals(SessionRecording.t()) :: :ok
  end

  def get_goal(id) do
    GoalQuery.from_goal()
    |> GoalQuery.preload_assocs()
    |> Repo.get(id)
  end

  def get_goals(%Project{id: project_id}, goal_ids) do
    GoalQuery.from_goal()
    |> GoalQuery.where_project_id(project_id)
    |> GoalQuery.where_id_in(goal_ids)
    |> GoalQuery.preload_assocs()
    |> Repo.all()
  end

  def get_goals(%Project{id: project_id}) do
    GoalQuery.from_goal()
    |> GoalQuery.where_project_id(project_id)
    |> GoalQuery.order_by_created_at_desc()
    |> GoalQuery.preload_assocs()
    |> Repo.all()
  end

  def get_goals_connected_to_split_test(%SplitTest{id: split_test_id}) do
    GoalQuery.from_goals()
    |> GoalQuery.where_split_test_id(split_test_id)
    |> GoalQuery.order_by_index()
    |> GoalQuery.preload_assocs()
    |> Repo.all()
  end

  def get_goals_count(%Project{id: project_id}, params \\ %{}) do
    GoalQuery.from_goal()
    |> GoalQuery.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  # def get_split_test_goal_conversions_count(goal_id) do
  #   SplitTestGoalConversion.from_goal_conversions()
  #   |> SplitTestGoalConversion.where_project_goal(goal_id)
  #   |> Repo.aggregate(:count, :id)
  # end

  def create_goal(%Project{id: project_id} = project, params) do
    case Goal.create_changeset(%Goal{project_id: project_id}, params) do
      %Changeset{valid?: true} = changeset ->
        goal = Repo.insert!(changeset)

        # TODO: convert goal

        {:ok, goal}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_goal(goal, params) do
    case Goal.update_changeset(goal, params) do
      %Changeset{valid?: true} = changeset ->
        # goal = Changeset.apply_changes(changeset)
        goal = Repo.update!(changeset)

        # goal = get_goal(%Project{id: goal.project_id}, goal.id)
        # if imporant fields changed, delete all conversions, convert again

        {:ok, goal}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def delete_goal(goal) do
    GoalQuery.from_goal()
    |> Repo.get(goal.id)
    |> Repo.delete!()

    {:ok, goal}
  end

  # def convert_goal(goal) do
  # end

  def convert_goals(%SessionRecording{} = session_recording) do
    project = Projects.get_project!(session_recording.project_id)
    goals = get_goals(project)
    do_convert_goals(goals, [session_recording])
  end

  @spec do_convert_goals([Goal.t()], [SessionRecording.t()]) :: :ok
  defp do_convert_goals(goals, session_recordings) do
    session_recordings
    |> Stream.chunk_every(500)
    |> Stream.map(fn chunked_session_recordings ->
      generate_entries(goals, chunked_session_recordings)
    end)
    |> Stream.map(fn entries ->
      Repo.insert_all(Conversion, entries, on_conflict: :nothing)
    end)
    |> Stream.run()
  end

  defp generate_entries(goals, session_recordings) do
    for goal <- goals,
        session_recording <- session_recordings,
        reduce: [] do
      entries ->
        case Goal.check_conversion(goal, session_recording) do
          {:ok, happened_at} ->
            [
              %{
                id: Ecto.UUID.generate(),
                goal_id: goal.id,
                session_recording_id: session_recording.id,
                happened_at: happened_at
              }
              | entries
            ]

          _ ->
            entries
        end
    end
  end
end
