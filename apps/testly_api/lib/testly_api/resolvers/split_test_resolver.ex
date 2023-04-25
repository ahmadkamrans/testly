defmodule TestlyAPI.SplitTestResolver do
  use TestlyAPI.Resolver
  alias Testly.{SplitTests, Goals, IdeaLab}
  alias Testly.SplitTests.{SplitTest, FinishCondition}
  alias Testly.Projects.Project

  alias Testly.SplitTests
  alias Testly.Projects.Project

  # def idea_for_split_test(category, args, %{context: %{loader: loader}}) do
  #   loader
  #   |> Dataloader.load(IdeaLab, {:items, args}, category)
  #   |> on_load(fn loader ->
  #     items = Dataloader.get(loader, Menu, {:items, args}, category)
  #     {:ok, items}
  #   end)
  # end

  def split_test(%Project{} = _project, %{id: id}, _res) do
    {:ok, SplitTests.get_split_test(id)}
  end

  def split_test_connection(%Project{id: project_id} = project, args, _resolution) do
    {:ok,
     %{
       nodes: SplitTests.get_split_tests(project, args),
       total_count: SplitTests.get_split_tests_count(project, args)
     }}
  end

  def split_tests_count(
        %{
          project_id: project_id,
          filter: filter
        },
        _args,
        _resolution
      ) do
    {:ok,
     SplitTests.get_split_tests_count(%Project{id: project_id},
       filter: filter
     )}
  end

  def goal(%FinishCondition{type: :goal_conversions, goal_id: goal_id}, _args, _res) do
    {:ok, Testly.Goals.get_goal(%SplitTest{}, goal_id)}
  end

  def create_split_test(%{split_test_params: split_test_params, project_id: project_id}, _res) do
    case SplitTests.create_split_test(%Project{id: project_id}, split_test_params) do
      {:ok, split_test} = ok -> ok
      {:error, changeset} -> {:ok, changeset}
    end
  end

  def update_split_test(%{split_test_params: split_test_params, split_test_id: split_test_id}, _res) do
    # TODO: auth
    split_test = SplitTests.get_split_test(split_test_id)

    case SplitTests.update_split_test(split_test, split_test_params) do
      {:ok, split_test} = ok -> ok
      {:error, changeset} -> {:ok, changeset}
    end
  end

  def activate_split_test(%{split_test_id: split_test_id}, _res) do
    split_test = SplitTests.get_split_test(split_test_id)
    SplitTests.run_split_test(split_test)
  end

  def pause_split_test(%{split_test_id: split_test_id}, _res) do
    split_test = SplitTests.get_split_test(split_test_id)
    SplitTests.pause_split_test(split_test)
  end

  def finish_split_test(%{split_test_id: split_test_id}, _res) do
    split_test = SplitTests.get_split_test(split_test_id)
    SplitTests.finish_split_test(split_test)
  end

  def conversion_reports(%SplitTest{} = split_test, %{goal_id: goal_id}, _resolution) do
    {:ok, []}
    # if Goals.get_goals(split_test) == [] do
    #   {:ok, []}
    # else
    #   goal = Goals.get_goal(%SplitTest{}, goal_id || List.first(Goals.get_goals(split_test)).id)
    #   {:ok, SplitTests.get_goal_variation_reports(split_test, goal)}
    # end
  end

  def goals(split_test, _args, _resolution) do
    {:ok, Goals.get_goals(split_test)}
  end

  def test_idea(%SplitTest{test_idea_id: nil}, _args, _resolution) do
    {:ok, nil}
  end

  def test_idea(%SplitTest{test_idea_id: id}, _args, _resolution) do
    {:ok, IdeaLab.get_idea(id)}
  end
end
