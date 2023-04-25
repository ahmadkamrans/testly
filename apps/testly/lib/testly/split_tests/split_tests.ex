defmodule Testly.SplitTests do
  defmodule Behaviour do
    @callback get_split_tests(Project.t(), [...]) :: [SplitTest.t()]
    @callback get_active_split_tests(Project.t()) :: [SplitTest.t()]
    @callback get_split_test(String.t()) :: SplitTest.t() | nil
    @callback get_visits_count(SplitTest.t()) :: non_neg_integer()
    @callback get_split_tests_count(Project.t()) :: integer()
    @callback get_split_tests_count(Project.t(), filter: Filter.t()) :: integer()
    @callback get_active_split_tests_count(Project.t()) :: integer()
    @callback get_finished_split_tests_count(Project.t()) :: integer()
    @callback get_page_types() :: [PageType.t()]
    @callback get_page_categories() :: [PageCategory.t()]
    @callback create_split_test(Project.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
    @callback update_split_test(SplitTest.t(), map()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
    @callback run_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
    @callback pause_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
    @callback finish_split_test(SplitTest.t()) :: {:ok, SplitTest.t()} | {:error, Changeset.t()}
    @callback maybe_finish_split_test(String.t()) :: SplitTest.t()
    @callback visit_split_test_variation(SplitTest.t(), String.t(), SessionRecording.t()) :: :ok
    @callback get_goal_variation_reports(SplitTest.t(), Goal.t()) :: [GoalVariationReport.t()]
    @callback find_variation(Project.t(), String.t()) :: Variation.t() | nil
  end

  @behaviour Behaviour

  alias Testly.{
    Repo,
    Pagination
  }

  alias Ecto.Multi
  alias Ecto.Changeset

  alias Testly.SplitTests.{
    SplitTest,
    VariationVisit,
    PageType,
    PageCategory,
    FinishCondition,
    GoalVariationReport,
    Variation,
    SplitTestFinishConditionChecker,
    Worker,
    SplitTestQuery,
    VariationQuery,
    VariationVisitQuery,
    ConversionReportQuery,
    SplitTestFilter,
    DataSource
  }

  alias Testly.SessionRecordings.{SessionRecording}
  alias Testly.Projects.Project
  alias Testly.Goals

  require Logger

  def data_source() do
    Dataloader.Ecto.new(Repo, query: &DataSource.query/2)
  end

  # def paginate_split_tests(%Project{id: project_id}, params \\ %{}) do
  #   filter =
  #     %SplitTestFilter{}
  #     |> SplitTestFilter.changeset(filter)
  #     |> Changeset.apply_changes()

  #   pagination =
  #     %Pagination{}
  #     |> Pagination.changeset(pagination)
  #     |> Changeset.apply_changes()

  #   SplitTestQuery.from_split_test()
  #   |> SplitTestFilter.query(filter)
  #   |> Pagination.query(pagination)
  #   |> SplitTestQuery.where_project_id(project_id)
  #   |> SplitTestQuery.order_by_created_at()
  #   |> Ecto.Query.distinct(true)
  #   |> SplitTestQuery.preload_assocs(variations_query())
  #   |> Repo.all()
  #   # |> Repo.scrivener_paginate(pagination)

  #   # %{:ok, }
  # end

  @impl true
  def get_split_tests(%Project{id: project_id}, params \\ %{}) do
    filter = SplitTestFilter.cast_params(params[:filter] || %{})
    pagination = Pagination.cast_params(params[:pagination] || %{})

    SplitTestQuery.from_split_test()
    |> SplitTestFilter.query(filter)
    |> Pagination.query(pagination)
    |> SplitTestQuery.where_project_id(project_id)
    |> SplitTestQuery.order_by_created_at()
    |> SplitTestQuery.distinct()
    |> SplitTestQuery.preload_assocs(variations_query())
    |> Repo.all()
  end

  @impl true
  def get_active_split_tests(%Project{id: project_id}) do
    SplitTestQuery.from_split_test()
    |> SplitTestQuery.where_project_id(project_id)
    |> SplitTestQuery.where_status_active()
    |> SplitTestQuery.preload_assocs(variations_query())
    |> Repo.all()
  end

  @impl true
  def get_split_test(id) do
    SplitTestQuery.from_split_test()
    |> SplitTestQuery.preload_assocs(variations_query())
    |> Repo.get(id)
  end

  @impl true
  def get_visits_count(%SplitTest{id: id}) do
    VariationVisitQuery.from_variation_visit()
    |> VariationVisitQuery.left_join_variation()
    |> VariationQuery.where_split_test_id(id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def get_split_tests_count(%Project{id: project_id}) do
    SplitTestQuery.from_split_test()
    |> SplitTestQuery.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def get_split_tests_count(%Project{id: project_id}, params) do
    filter = SplitTestFilter.cast_params(params[:filter] || %{})

    SplitTestQuery.from_split_test()
    |> SplitTestQuery.where_project_id(project_id)
    |> SplitTestFilter.query(filter)
    |> SplitTestQuery.distinct()
    |> Repo.aggregate(:count, :id)
  end

  def stream_all_split_tests(statuses: statuses) do
    SplitTestQuery.from_split_tests()
    |> SplitTestQuery.where_status_in(statuses)
    |> Repo.stream()
  end

  def preload_all(split_tests) do
    split_tests
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition,
      variations: {variations_query(), [visits: [:session_recording]]}
    ])
  end

  def get_split_tests_with_visits_to(%SessionRecording{id: session_recording_id}) do
    SplitTest.where_visits_to(session_recording_id)
    |> Repo.all()
    |> Repo.preload([
      :page_category,
      :page_type,
      :finish_condition
    ])
  end

  def get_split_test_with_visits_to(%SplitTest{id: id}) do
    SplitTest
    |> Repo.get(id)
    |> preload_all()
  end

  @impl true
  def get_page_types do
    PageType
    |> Repo.all()
  end

  @impl true
  def get_page_categories do
    PageCategory
    |> Repo.all()
  end

  @impl true
  def create_split_test(%Project{id: project_id}, params) do
    %SplitTest{project_id: project_id}
    |> SplitTest.create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def update_split_test(split_test, params) do
    goals = load_goals(%Project{id: split_test.project_id}, params)

    split_test
    |> SplitTest.update_changeset(params, goals)
    |> Repo.update()
  end

  defp load_goals(project, params) do
    case params[:goal_ids] || [] do
      [] -> []
      goal_ids -> Goals.get_goals(project, goal_ids)
    end
  end

  @impl true
  def activate_split_test(split_test) do
    split_test
    |> SplitTest.activate_changeset()
    |> Repo.update()
  end

  @impl true
  def pause_split_test(split_test) do
    split_test
    |> SplitTest.pause_changeset()
    |> Repo.update()
  end

  @impl true
  def finish_split_test(split_test) do
    split_test
    |> SplitTest.finish_changeset()
    |> Repo.update()
  end

  @impl true
  def maybe_finish_split_test(split_test) do
    if SplitTestFinishConditionChecker.check(split_test) do
      {:ok, finised_split_test} = finish_split_test(split_test)

      finised_split_test
    else
      split_test
    end
  end

  @impl true
  def visit_split_test_variation(split_test, variation_id, %SessionRecording{id: session_recording_id}) do
    %VariationVisit{
      split_test_variation_id: variation_id,
      session_recording_id: session_recording_id
    }
    |> Repo.insert!(on_conflict: :nothing)

    # case split_test.finish_condition do
    #   %VisitsFinishCondition{} ->
    #     maybe_finish_split_test(get_split_test(split_test.id))

    #   _ ->
    #     nil
    # end

    :ok
  end

  @impl true
  def get_goal_variation_reports(split_test, goal) do
    variation_ids = Enum.map(split_test.variations, & &1.id)

    ConversionReportQuery.from_schema()
    |> ConversionReportQuery.where_goal_id(goal.id)
    |> ConversionReportQuery.where_variation_id_in(variation_ids)
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

  # @impl true
  # def find_variation(%Project{id: project_id}, url) do
  #   split_tests = get_active_split_tests(%Project{id: project_id})

  #   split_test =
  #     Enum.find(split_tests, fn split_test ->
  #       split_test.variations
  #       |> Enum.map(& &1.url)
  #       |> Enum.member?(url)
  #     end)

  #   case split_test do
  #     %SplitTest{} ->
  #       SplitTest.determine_variation_for_visit(split_test)

  #     nil ->
  #       nil
  #   end
  # end

  defp variations_query do
    VariationQuery.from_variation()
    |> VariationQuery.order_by_index()
  end
end
