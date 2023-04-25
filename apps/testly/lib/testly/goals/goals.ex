defmodule Testly.Goals do
  alias Testly.Repo

  alias Testly.Goals.{
    Goal,
    ProjectGoal,
    SplitTestGoal,
    SplitTestGoalConversion,
    ProjectGoalConversion
  }

  alias Testly.SplitTests.{SplitTest, GoalConversionsFinishCondition, VariationVisit}
  alias Testly.Projects.Project
  alias Testly.{Projects, SplitTests}
  alias Testly.SessionRecordings
  alias Testly.SessionRecordings.{SessionRecording}
  alias Ecto.Changeset

  @spec get_goal(Goal.assoc(), String.t(), preload_conversions: boolean()) :: Goal.goal() | nil
  def get_goal(entity, id, options \\ [preload_conversions: true])
  def get_goal(%SplitTest{}, id, options) do
    preload_conversions = options[:preload_conversions]

    SplitTestGoal
    |> Repo.get(id)
    |> case do
      goal when preload_conversions == true -> Repo.preload(goal, [:conversions])
      g -> g
    end
    |> Goal.to_goal()
  end

  def get_goal(%Project{}, id, options) do
    preload_conversions = options[:preload_conversions]

    ProjectGoal
    |> Repo.get(id)
    |> case do
      goal when preload_conversions == true -> Repo.preload(goal, [:conversions])
      g -> g
    end
    |> Goal.to_goal()
  end

  @spec get_goals(Goal.assoc(), preload_conversions: boolean()) :: [Goal.goal()]
  def get_goals(entity, options \\ [preload_conversions: true])
  def get_goals(%SplitTest{id: split_test_id}, options) do
    preload_conversions = options[:preload_conversions]

    SplitTestGoal.from_goals()
    |> SplitTestGoal.where_split_test_id(split_test_id)
    |> SplitTestGoal.order_by_index()
    |> Repo.all()
    |> case do
      goal when preload_conversions == true -> Repo.preload(goal, [:conversions])
      g -> g
    end
    |> Enum.map(&Goal.to_goal/1)
  end

  def get_goals(%Project{id: project_id}, options) do
    preload_conversions = options[:preload_conversions]

    ProjectGoal.from_goals()
    |> ProjectGoal.where_project_id(project_id)
    |> ProjectGoal.order_by_created_at_desc()
    |> Repo.all()
    |> case do
      goal when preload_conversions == true -> Repo.preload(goal, [:conversions])
      g -> g
    end
    |> Enum.map(&Goal.to_goal/1)
  end

  def get_first_goal_id(%SplitTest{id: split_test_id}) do
    SplitTestGoal.from_goals()
    |> SplitTestGoal.where_split_test_id(split_test_id)
    |> SplitTestGoal.order_by_index()
    |> Repo.all()
    |> List.first()
    |> Map.fetch!(:id)
  end

  @spec get_goals_count(Goal.assoc()) :: integer
  def get_goals_count(%Project{id: project_id}) do
    ProjectGoal.from_goals()
    |> ProjectGoal.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  @spec get_split_test_goal_conversions_count(String.t()) :: integer()
  def get_split_test_goal_conversions_count(goal_id) do
    SplitTestGoalConversion.from_goal_conversions()
    |> SplitTestGoalConversion.where_project_goal(goal_id)
    |> Repo.aggregate(:count, :id)
  end

  # @spec create_goal(Goal.assoc(), map()) :: {:ok, Goal.goal()} | {:error, Changeset.t()}
  # def create_goal(%SplitTest{id: split_test_id} = _split_test, params) do
  #   case Goal.changeset(split_test_id, params) do
  #     %Changeset{valid?: true} = changeset ->
  #       goal = Changeset.apply_changes(changeset)

  #       %SplitTestGoal{}
  #       |> SplitTestGoal.changeset(goal)
  #       |> Repo.insert!()

  #       # TODO: reach worker
  #       # goal = get_goal(split_test, split_test_goal.id)

  #       {:ok, goal}

  #     %Changeset{valid?: false} = changeset ->
  #       {:error, changeset}
  #   end
  # end

  def create_goal(%Project{id: project_id} = project, params) do
    case Goal.changeset(project_id, params) do
      %Changeset{valid?: true} = changeset ->
        goal = Changeset.apply_changes(changeset)

        project_goal =
          %ProjectGoal{}
          |> ProjectGoal.changeset(goal)
          |> Repo.insert!()

        goal = get_goal(project, project_goal.id)

        # TODO: convert worker

        {:ok, goal}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @spec update_goal(Goal.assoc(), Goal.goal(), map()) ::
          {:ok, Goal.goal()} | {:error, Changeset.t()}
  def update_goal(%Project{}, goal, params) do
    case Goal.update_changeset(goal, params) do
      %Changeset{valid?: true} = changeset ->
        goal = Changeset.apply_changes(changeset)

        ProjectGoal
        |> Repo.get(goal.id)
        |> ProjectGoal.changeset(goal)
        |> Repo.update!()

        # goal = get_goal(%Project{id: goal.assoc_id}, goal.id)

        # TODO: convert worker

        {:ok, goal}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # def update_goal(%SplitTest{}, goal, params) do
  #   case Goal.update_changeset(goal.assoc_id, params) do
  #     %Changeset{valid?: true} = changeset ->
  #       project_goal =
  #         changeset
  #         |> Changeset.apply_changes()
  #         |> ProjectGoal.to_project_goal

  #       {:ok, %{project_goal: project_goal}} =
  #         Multi.new()
  #         |> Multi.update(:project_goal, project_goal)
  #         |> Multi.delete_all(:conversions, Ecto.assoc(project_goal, :conversions))
  #         |> Repo.transaction()

  #         # TODO: reach worker

  #       {:ok, Goal.to_goal(project_goal)}

  #     %Changeset{valid?: false} = changeset ->
  #       {:error, changeset}
  #   end
  # end

  @callback update_goals(SplitTest.t(), [map()]) :: {:ok, :goals} | {:error, [Changeset.t()]}
  def update_goals(%SplitTest{id: split_test_id} = split_test, goals_params) do
    goals = get_goals(split_test)

    case Goal.changesets(split_test_id, goals, goals_params) do
      {:ok, changesets} ->
        for changeset <- changesets do
          goal = Changeset.apply_changes(changeset)

          case changeset do
            %{action: :insert} ->
              %SplitTestGoal{}
              |> SplitTestGoal.changeset(goal)
              |> Repo.insert!()

            %{action: :update} ->
              SplitTestGoal
              |> Repo.get(goal.id)
              |> SplitTestGoal.changeset(goal)
              |> Repo.update!()

            %{action: :delete} ->
              SplitTestGoal
              |> Repo.get(goal.id)
              |> Repo.delete!()
          end
        end

        {:ok, :goals}

      {:error, _} = error ->
        error
    end
  end

  @spec delete_goal(Goal.assoc(), Goal.goal()) :: {:ok, Goal.goal()}
  def delete_goal(%Project{}, goal) do
    ProjectGoal
    |> Repo.get(goal.id)
    |> Repo.delete!()

    {:ok, goal}
  end

  # def delete_goal(%SplitTest{}, goal) do
  #   goal
  #   |> SplitTestGoal.to_split_test_goal()
  #   |> Repo.delete!()

  #   :ok
  # end

  @spec convert_goals(SessionRecording.t()) :: :ok
  def convert_goals(%SessionRecording{} = session_recording) do
    project = Projects.get_project(session_recording.project_id)
    project_goals = get_goals(project)
    :ok = convert_goals(project, project_goals, [session_recording])

    split_tests = SplitTests.get_split_tests_with_visits_to(session_recording)
    split_test = List.first(split_tests)

    if split_test do
      split_test_goals = get_goals(split_test)

      visit =
        Enum.map(split_test.variations, fn variation ->
          Enum.find(variation.visits, &(&1.session_recording_id == session_recording.id))
        end)
        |> Enum.reject(&is_nil/1)
        |> List.first()

      visit = %VariationVisit{visit | session_recording_id: session_recording.id}

      # session_recording => visits => variation => split_test

      :ok = convert_goals(split_test, split_test_goals, [visit])

      case split_test.finish_condition do
        %GoalConversionsFinishCondition{} ->
          SplitTests.maybe_finish_split_test(SplitTests.get_split_test(split_test.id))

        _ ->
          nil
      end
    end

    :ok
  end

  # def convert_goals(%SplitTest{} = split_test, %VariationVisit{} = visit) do
  #   session_recording = SessionRecordings.get_session_recording(visit.session_recording_id)
  #   goals = get_goals(split_test)
  #   visit = %{visit | session_recording: session_recording}

  #   convert_goals(split_test, goals, [visit])
  # end

  # @spec convert_goal_for_session_recordings(Goal.goal()) :: :ok
  # def reconvert_goal(project, goal) do
  #   session_recordings = SessionRecordings.get_session_recordings(project.id)
  #   convert_goals(project, [goal], session_recordings)
  # end

  # def reconvert_goal(split_test, goal) do
  #   # SplitTtests.get_visits()
  #   session_recordings = SessionRecordings.get_session_recordings(goal.assoc_id)
  #   convert_goals(split_test, [goal], session_recordings)
  # end

  # @spec convert_goals([Goal.goal()], [SessionRecording.t()]) :: :ok
  defp convert_goals(%Project{}, goals, session_recordings) do
    session_recordings
    |> Stream.chunk_every(500)
    |> Stream.map(fn chunked_session_recordings ->
      for goal <- goals,
          session_recording <- chunked_session_recordings do
        case Goal.check_conversion(goal, session_recording) do
          {:ok, conversion_happened_at} ->
            %{
              id: Ecto.UUID.generate(),
              project_goal_id: goal.id,
              session_recording_id: session_recording.id,
              happened_at: conversion_happened_at
            }

          {:error, _} ->
            nil
        end
      end
    end)
    |> Stream.map(fn entries ->
      entries = Enum.reject(entries, &is_nil/1)
      Repo.insert_all(ProjectGoalConversion, entries, on_conflict: :nothing)
    end)
    |> Stream.run()

    :ok
  end

  # @spec convert_goals([Goal.goal()], [VariationVisit.t()]) :: :ok
  defp convert_goals(%SplitTest{}, goals, visits) do
    visits
    |> Stream.chunk_every(500)
    |> Stream.map(fn chunked_visits ->
      for goal <- goals, visit <- chunked_visits do
        case Goal.check_conversion(goal, SessionRecordings.get_session_recording(visit.session_recording_id)) do
          {:ok, conversion_happened_at} ->
            %{
              id: Ecto.UUID.generate(),
              split_test_goal_id: goal.id,
              split_test_variation_visit_id: visit.id,
              happened_at: conversion_happened_at
            }

          {:error, _} ->
            nil
        end
      end
    end)
    |> Stream.map(fn entries ->
      entries = Enum.reject(entries, &is_nil/1)
      Repo.insert_all(SplitTestGoalConversion, entries, on_conflict: :nothing)
    end)
    |> Stream.run()

    :ok
  end
end
