defmodule TestlyAPI.Schema.SplitTestTypes do
  use Absinthe.Schema.Notation

  import_types(TestlyAPI.Schema.SplitTest.FinishConditionTypes)
  import_types(TestlyAPI.Schema.SplitTest.VariationConversionTypes)

  alias Testly.SplitTests
  alias Testly.SplitTests.{SplitTest}
  alias Testly.Goals
  alias Testly.Projects.Project
  alias Testly.IdeaLab
  alias Testly.SplitTests.Filter, as: SplitTestsFilter

  # alias TestlyAPI.Schema.Mock

  enum(:split_test_status,
    values: [
      :draft,
      :active,
      :paused,
      :finished
    ]
  )

  input_object :split_test_filter do
    field :name_cont, :string
    field :created_at_gteq, :datetime
    field :created_at_lteq, :datetime
    field :status_in, list_of(non_null(:split_test_status))
    field :page_type_id_in, list_of(non_null(:uuid4))
    field :page_category_id_in, list_of(non_null(:uuid4))
  end

  object :page_category do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
  end

  object :page_type do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
  end

  object :split_test_variation do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
    field :url, non_null(:string)
    field :control, non_null(:boolean)
  end

  object :split_test do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :page_category, non_null(:page_category)
    field :page_type, non_null(:page_type)
    field :status, non_null(:split_test_status)

    field :test_idea, :test_idea do
      resolve(fn
        %SplitTest{test_idea_id: nil}, _args, _resolution -> {:ok, nil}
        %SplitTest{test_idea_id: id}, _args, _resolution -> {:ok, IdeaLab.get_idea(id)}
      end)
    end

    field :variations, non_null(list_of(non_null(:split_test_variation))),
      description: "Can be empty only in draft state"

    field :goals, non_null(list_of(non_null(:goal))), description: "Can be empty only in draft state" do
      resolve(fn split_test, _args, _resolution ->
        {:ok, Goals.get_goals(split_test, preload_conversions: false)}
      end)
    end

    field :finish_condition, :split_test_finish_condition, description: "Can be null only in draft state"

    field :traffic_percent, non_null(:integer)
    field :traffic_device_types, non_null(list_of(non_null(:device_type)))
    field :traffic_referrer_sources, non_null(list_of(non_null(:referrer_source)))

    field :variations_conversions, non_null(list_of(non_null(:split_test_variation_conversion))) do
      arg(:goal_id, :uuid4, default_value: nil)

      resolve(fn %SplitTest{} = split_test, %{goal_id: goal_id}, _resolution ->
        if Goals.get_goals(split_test, preload_conversions: false) == [] do
          {:ok, []}
        else
          goal =
            Goals.get_goal(%SplitTest{}, goal_id || Goals.get_first_goal_id(split_test), preload_conversions: false)

          {:ok, SplitTests.get_goal_variation_reports(split_test, goal)}
        end
      end)
    end
  end

  object :split_tests_connection do
    field :split_tests, non_null(list_of(non_null(:split_test))) do
      resolve(fn %{
                   project_id: project_id,
                   page: page,
                   per_page: per_page,
                   filter: filter
                 },
                 _args,
                 _resolution ->
        {:ok,
         SplitTests.get_split_tests(%Project{id: project_id},
           page: page,
           per_page: per_page,
           filter: filter
         )}
      end)
    end

    field(:total_records, non_null(:integer)) do
      resolve(fn %{
                   project_id: project_id,
                   filter: filter
                 },
                 _args,
                 _resolution ->
        {:ok,
         SplitTests.get_split_tests_count(%Project{id: project_id},
           filter: filter
         )}
      end)
    end

    field(:active_tests, non_null(:integer))
    field(:finished_tests, non_null(:integer))
  end

  object :split_test_queries do
    field :split_test, :split_test do
      arg(:id, non_null(:uuid4))

      resolve(fn %Project{} = _project, %{id: id}, %{context: %{current_project_user: _current_project_user}} ->
        # TODO: auth

        {:ok, SplitTests.get_split_test(id)}
      end)
    end

    field :split_tests_connection, non_null(:split_tests_connection) do
      arg(:page, :integer, default_value: 1)
      arg(:per_page, :integer, default_value: 10)
      arg(:filter, :split_test_filter)

      resolve(fn %Project{id: project_id} = project, %{page: page, per_page: per_page} = args, _resolution ->
        filter = struct(SplitTestsFilter, args[:filter] || %{})

        {:ok,
         %{
           project_id: project_id,
           filter: filter,
           page: page,
           per_page: per_page,
           active_tests: SplitTests.get_active_split_tests_count(project),
           finished_tests: SplitTests.get_finished_split_tests_count(project)
         }}
      end)
    end
  end
end
