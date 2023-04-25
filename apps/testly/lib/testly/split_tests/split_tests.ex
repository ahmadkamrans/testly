defmodule Testly.SplitTests do
  @moduledoc """
    Split Tests Context
  """

  alias Testly.Repo
  alias Ecto.Multi
  alias Ecto.Changeset

  alias Testly.SplitTests.{
    SplitTest,
    VariationVisit,
    PageType,
    PageCategory,
    FinishConditionDb,
    FinishCondition,
    GoalVariationReport,
    Variation,
    SplitTestFinishConditionChecker,
    VisitsFinishCondition,
    DaysPassedFinishCondition,
    GoalConversionsFinishCondition,
    FinishSplitTestWorker,
    Filter
  }

  alias Testly.SessionRecordings.{SessionRecording}
  alias Testly.Projects.Project
  alias Testly.Goals
  alias Testly.Goals.Goal

  import Ecto.Query

  require Logger

  @callback get_split_tests(Project.t()) :: [SplitTest.t()]
  def get_split_tests(%Project{id: project_id}, page: page, per_page: per_page, filter: filter) do
    variations = Variation.from_variations() |> Variation.order_by_index()

    Filter.filter(filter)
    |> SplitTest.where_project_id(project_id)
    |> SplitTest.paginate(page, per_page)
    |> SplitTest.distinct()
    |> SplitTest.order_by_created_at()
    |> Repo.all()
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition_db,
      variations: variations
    ])
    |> SplitTest.preload_finish_condition()
  end

  @callback get_active_split_tests(Project.t()) :: [SplitTest.t()]
  def get_active_split_tests(%Project{id: project_id}) do
    variations = Variation.from_variations() |> Variation.order_by_index()

    SplitTest.from_split_tests()
    |> SplitTest.where_project_id(project_id)
    |> SplitTest.where_status_active()
    |> Repo.all()
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition_db,
      variations: variations
    ])
    |> SplitTest.preload_finish_condition()
  end

  @callback get_split_test(String.t()) :: SplitTest.t() | nil
  def get_split_test(id) do
    variations = Variation.from_variations() |> Variation.order_by_index()

    SplitTest
    |> Repo.get(id)
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition_db,
      variations: variations
    ])
    |> SplitTest.preload_finish_condition()
  end

  @spec get_visits_count(SplitTest.t()) :: non_neg_integer()
  def get_visits_count(%SplitTest{id: id}) do
    from(
      v_v in VariationVisit,
      left_join: v in assoc(v_v, :variation),
      where: v.split_test_id == ^id
    )
    |> Repo.aggregate(:count, :id)
  end

  @callback get_split_tests_count(Project.t()) :: integer()
  def get_split_tests_count(%Project{id: project_id}) do
    SplitTest.from_split_tests()
    |> SplitTest.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  @callback get_split_tests_count(Project.t(), filter: Filter.t()) :: integer()
  def get_split_tests_count(%Project{id: project_id}, filter: filter) do
    Filter.filter(filter)
    |> SplitTest.where_project_id(project_id)
    |> SplitTest.distinct()
    |> Repo.aggregate(:count, :id)
  end

  @callback get_active_split_tests_count(Project.t()) :: integer()
  def get_active_split_tests_count(%Project{id: project_id}) do
    SplitTest.from_split_tests()
    |> SplitTest.where_project_id(project_id)
    |> SplitTest.where_status_active()
    |> Repo.aggregate(:count, :id)
  end

  @callback get_finished_split_tests_count(Project.t()) :: integer()
  def get_finished_split_tests_count(%Project{id: project_id}) do
    SplitTest.from_split_tests()
    |> SplitTest.where_project_id(project_id)
    |> SplitTest.where_status_finished()
    |> Repo.aggregate(:count, :id)
  end

  def stream_all_split_tests(statuses: statuses) do
    SplitTest.from_split_tests()
    |> SplitTest.where_status_in(statuses)
    |> Repo.stream()
  end

  def preload_all(split_tests) do
    variations = Variation.from_variations() |> Variation.order_by_index()

    split_tests
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition_db,
      variations: {variations, [:visits]}
    ])
  end

  def get_split_tests_with_visits_to(%SessionRecording{id: session_recording_id}) do
    SplitTest.where_visits_to(session_recording_id)
    |> Repo.all()
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition_db
    ])
    |> SplitTest.preload_finish_condition()
  end

  def get_split_test_with_visits_to(%SplitTest{id: id}) do
    SplitTest
    |> Repo.get(id)
    |> preload_all()
    |> SplitTest.preload_finish_condition()
  end

  # @callback get_split_test_by(String.t()) :: SplitTest.t() | nil
  # def get_split_test_by(project_id, clauses) do
  #   SplitTest.from_split_tests
  #   |> SplitTest.where_project_id(project_id)
  #   |> Repo.get_by(clauses)
  #   |> Repo.preload([:finish_condition, variations: [:visits]])
  # end

  @callback get_page_types() :: [PageType.t()]
  def get_page_types do
    PageType
    |> Repo.all()
  end

  @callback get_page_types() :: [PageCategory.t()]
  def get_page_categories do
    PageCategory
    |> Repo.all()
  end

  @callback create_split_test(Project.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  def create_split_test(%Project{id: project_id}, params) do
    %SplitTest{project_id: project_id}
    |> SplitTest.create_changeset(params)
    |> Repo.insert()
  end

  @callback update_split_test(SplitTest.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  def update_split_test(split_test, params) do
    result =
      Multi.new()
      |> Multi.run(:split_test, fn _repo, _changes ->
        split_test
        |> SplitTest.update_changeset(params)
        |> Repo.update()
      end)
      |> Multi.run(:finish_condition, fn _repo, _changes ->
        if params[:finish_condition] do
          case FinishCondition.changeset(split_test, params[:finish_condition]) do
            %Changeset{valid?: true} = changeset ->
              finish_condition = Changeset.apply_changes(changeset)

              %FinishConditionDb{}
              |> FinishConditionDb.changeset(finish_condition)
              |> Repo.insert(on_conflict: {:replace_all_except, [:id]}, conflict_target: :id)

            %Changeset{valid?: false} = changeset ->
              {:error, changeset}
          end
        else
          {:ok, :finish_condition}
        end
      end)
      |> Multi.run(:goals, fn _repo, %{split_test: split_test} ->
        if params[:goals] do
          Goals.update_goals(split_test, params[:goals])
        else
          {:ok, :goals}
        end
      end)
      |> Repo.transaction()

    updated_split_test = get_split_test(split_test.id)

    case result do
      {:ok, %{split_test: _split_test, goals: _goals}} ->
        enqueue_finish(updated_split_test)
        {:ok, updated_split_test}

      {:error, :split_test, changeset, _changes} ->
        {:error, changeset}

      {:error, :goals, changesets, _changes} ->
        {:error, changesets}
    end
  end

  # It should work for split test with any status
  # Otherwise test will not be enqued on create(
  #   cause test will have `Pause` state on update_split_test/2 action
  # )
  def enqueue_finish(
        %SplitTest{
          id: id,
          finish_condition: %DaysPassedFinishCondition{count: count},
          created_at: created_at
        } = split_test
      ) do
    time = Timex.shift(created_at, days: count)
    Logger.info("SplitTest##{split_test.id} with #{inspect(split_test.finish_condition)} is enqueued at #{time}")
    FinishSplitTestWorker.enqueue(id, time)
    :ok
  end

  def enqueue_finish(_split_test), do: nil

  # @spec update_split_test_variations(SplitTest.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  # def update_split_test_variations(split_test, params) do
  #   split_test
  #   |> SplitTest.variations_changeset(params)
  #   |> Repo.update()
  # end

  # @spec update_split_test_settings(SplitTest.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  # def update_split_test_settings(split_test, params) do
  #   split_test
  #   |> SplitTest.settings_changeset(params)
  #   |> Repo.update()
  # end

  @callback run_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  def run_split_test(split_test) do
    # TODO: validate that all required fields is there
    split_test
    |> SplitTest.run_changeset()
    |> Repo.update()
  end

  @callback pause_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  def pause_split_test(split_test) do
    split_test
    |> SplitTest.pause_changeset()
    |> Repo.update()
  end

  @callback finish_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
  def finish_split_test(split_test) do
    split_test
    |> SplitTest.finish_changeset()
    |> Repo.update()
  end

  @callback maybe_finish_split_test(String.t()) :: SplitTest.t()
  def maybe_finish_split_test(split_test) do
    if check_finish_condition(split_test) do
      {:ok, finised_split_test} = finish_split_test(split_test)

      finised_split_test
    else
      split_test
    end
  end

  defp check_finish_condition(%SplitTest{finish_condition: %DaysPassedFinishCondition{}} = split_test) do
    SplitTestFinishConditionChecker.check(split_test)
  end

  defp check_finish_condition(
         %SplitTest{finish_condition: %GoalConversionsFinishCondition{goal_id: goal_id}} = split_test
       ) do
    SplitTestFinishConditionChecker.check(split_test, Goals.get_split_test_goal_conversions_count(goal_id))
  end

  defp check_finish_condition(%SplitTest{finish_condition: %VisitsFinishCondition{}} = split_test) do
    SplitTestFinishConditionChecker.check(split_test, get_visits_count(split_test))
  end

  @callback visit_split_test_variation(SplitTest.t(), String.t(), SessionRecording.t()) :: :ok
  def visit_split_test_variation(split_test, variation_id, %SessionRecording{
        id: session_recording_id,
        created_at: visited_at
      }) do
    %VariationVisit{
      split_test_variation_id: variation_id,
      session_recording_id: session_recording_id,
      visited_at: visited_at
    }
    |> Repo.insert!(on_conflict: :nothing)

    case split_test.finish_condition do
      %VisitsFinishCondition{} ->
        maybe_finish_split_test(get_split_test(split_test.id))

      _ ->
        nil
    end

    :ok
  end

  @callback get_goal_variation_reports(SplitTest.t(), Goal.t()) :: [GoalVariationReport.t()]
  def get_goal_variation_reports(split_test, goal) do
    variation_ids = Enum.map(split_test.variations, & &1.id)

    from(g_v_r in GoalVariationReport, where: g_v_r.variation_id in ^variation_ids and g_v_r.goal_id == ^goal.id)
    |> Repo.all()
    |> case do
      [] ->
        Logger.info("Generating split test report!")

        split_test_with_visits = get_split_test_with_visits_to(split_test)

        for variation <- split_test_with_visits.variations do
          GoalVariationReport.generate_report(goal, variation)
          |> GoalVariationReport.put_rates_by_date_reports(
            goal,
            variation,
            DateTime.to_date(split_test_with_visits.created_at),
            if(split_test.finished_at, do: DateTime.to_date(split_test.finished_at), else: Date.utc_today())
          )
        end
        |> GoalVariationReport.put_improvement_rate()

      reports ->
        reports
    end
    |> GoalVariationReport.put_is_winner(split_test.status === :finished)
  end

  @callback find_variation(Project.t(), String.t()) :: Variation.t() | nil
  def find_variation(%Project{id: project_id}, url) do
    split_tests = get_active_split_tests(%Project{id: project_id})

    split_test =
      Enum.find(split_tests, fn split_test ->
        split_test.variations
        |> Enum.map(& &1.url)
        |> Enum.member?(url)
      end)

    case split_test do
      %SplitTest{} ->
        SplitTest.determine_variation_for_visit(split_test)

      nil ->
        nil
    end
  end
end
