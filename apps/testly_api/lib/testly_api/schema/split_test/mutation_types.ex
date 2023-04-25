defmodule TestlyAPI.Schema.SplitTest.MutationTypes do
  use Absinthe.Schema.Notation

  alias Testly.SplitTests
  alias Testly.Projects.Project

  import(Kronky.Payload, only: :functions)
  import(TestlyAPI.Schema.Payload)

  payload_object(:split_test_payload, :split_test)

  input_object :variation_params do
    field :id, :uuid4
    field :name, non_null(:string)
    field :url, non_null(:string)
    field :control, non_null(:boolean)
  end

  input_object :finish_condition_params do
    field :type, non_null(:split_test_finish_condition_type)

    field :count, non_null(:integer), description: "Required for: days_passed, goal_conversions, visits"
    field :goal_id, :uuid4, description: "Required for: goal_conversions"
  end

  input_object :split_test_params do
    field :name, :string
    field :description, :string
    field :page_category_id, :uuid4
    field :page_type_id, :uuid4
    field :test_idea_id, :uuid4

    field :goals, list_of(non_null(:goal_params))
    field :variations, list_of(non_null(:variation_params))
    field :finish_condition, :finish_condition_params

    field :traffic_percent, :integer
    field :traffic_device_types, list_of(non_null(:device_type))
    field :traffic_referrer_sources, list_of(non_null(:referrer_source))
  end

  object :split_test_mutations do
    field :create_split_test, :split_test_payload do
      arg(:split_test_params, non_null(:split_test_params))
      arg(:project_id, non_null(:uuid4))

      resolve(fn %{split_test_params: split_test_params, project_id: project_id},
                 %{context: %{current_project_user: _current_project_user}} ->
        {:ok, %SplitTests.SplitTest{id: id}} = SplitTests.create_split_test(%Project{id: project_id}, split_test_params)

        {:ok, SplitTests.get_split_test(id)}
      end)

      middleware(&build_payload/2)
    end

    field :activate_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))

      resolve(fn %{split_test_id: split_test_id}, %{context: %{current_project_user: _current_project_user}} ->
        split_test = SplitTests.get_split_test(split_test_id)
        SplitTests.run_split_test(split_test)
      end)
    end

    field :pause_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))

      resolve(fn %{split_test_id: split_test_id}, %{context: %{current_project_user: _current_project_user}} ->
        split_test = SplitTests.get_split_test(split_test_id)
        SplitTests.pause_split_test(split_test)
      end)
    end

    field :finish_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))

      resolve(fn %{split_test_id: split_test_id}, %{context: %{current_project_user: _current_project_user}} ->
        split_test = SplitTests.get_split_test(split_test_id)
        SplitTests.finish_split_test(split_test)
      end)
    end

    field :update_split_test, :split_test_payload do
      arg(:split_test_id, non_null(:uuid4))
      arg(:split_test_params, non_null(:split_test_params))

      resolve(fn %{split_test_params: split_test_params, split_test_id: split_test_id},
                 %{context: %{current_project_user: _current_project_user}} ->
        split_test = SplitTests.get_split_test(split_test_id)
        SplitTests.update_split_test(split_test, split_test_params)

        {:ok, SplitTests.get_split_test(split_test_id)}
      end)

      middleware(&build_payload/2)
    end
  end
end
