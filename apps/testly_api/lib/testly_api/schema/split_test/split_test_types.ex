defmodule TestlyAPI.Schema.SplitTestTypes do
  use TestlyAPI.Schema.Notation

  alias TestlyAPI.SplitTestResolver
  alias Testly.SplitTests.{FinishCondition}

  enum(:split_test_finish_condition_type,
    values: [
      :goal_conversions,
      :visits,
      :days_passed
    ]
  )

  enum(:split_test_status,
    values: [
      :draft,
      :active,
      :paused,
      :finished
    ]
  )

  union :split_test_finish_condition do
    types([
      :split_test_goal_conversions_finish_condition,
      :split_test_visits_finish_condition,
      :split_test_days_passed_finish_condition
    ])

    resolve_type(fn
      %FinishCondition{type: :visits}, _ -> :split_test_visits_finish_condition
      %FinishCondition{type: :days_passed}, _ -> :split_test_days_passed_finish_condition
      %FinishCondition{type: :goal_conversions}, _ -> :split_test_goal_conversions_finish_condition
    end)
  end

  object :split_test_goal_conversions_finish_condition do
    field(:count, non_null(:integer))

    field(:goal, non_null(:goal)) do
      resolve(&SplitTestResolver.goal/3)
    end
  end

  object :split_test_visits_finish_condition do
    field(:count, non_null(:integer))
  end

  object :split_test_days_passed_finish_condition do
    field(:count, non_null(:integer))
  end

  payload_object(:split_test_payload, :split_test)

  input_object :split_test_variation_params do
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
    field :goal_ids, list_of(non_null(:uuid4))
    field :variations, list_of(non_null(:split_test_variation_params))
    field :finish_condition, :finish_condition_params
    field :traffic_percent, :integer
    field :traffic_device_types, list_of(non_null(:device_type))
    field :traffic_referrer_sources, list_of(non_null(:referrer_source))
  end

  input_object :split_test_filter do
    field :name_cont, :string
    field :created_at_gteq, :datetime
    field :created_at_lteq, :datetime
    field :status_in, list_of(non_null(:split_test_status))
    field :page_type_id_in, list_of(non_null(:uuid4))
    field :page_category_id_in, list_of(non_null(:uuid4))
  end

  object :split_test_variation_conversion_rate_by_date do
    field :date, non_null(:date)
    field :conversion_rate, non_null(:float)
  end

  object :split_test_conversion_report do
    field :conversion_rate, non_null(:float)
    field :conversions_count, non_null(:integer)
    field :visits_count, non_null(:integer)
    field :improvement_rate, :float
    field :is_winner, non_null(:boolean)
    field :revenue, non_null(:decimal)
    field :goal_id, non_null(:uuid4)
    field :variation_id, non_null(:uuid4)

    field :rates_by_date, non_null(list_of(non_null(:split_test_variation_conversion_rate_by_date)))
  end

  object :split_test_page_category do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
  end

  object :split_test_page_type do
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
    field :page_category, non_null(:split_test_page_category)
    field :page_type, non_null(:split_test_page_type)
    field :status, non_null(:split_test_status)

    field :test_idea, :test_idea do
      resolve(&SplitTestResolver.test_idea/3)
    end

    field :variations, non_null(list_of(non_null(:split_test_variation))),
      description: "Can be empty only in draft state"

    field :goals, non_null(list_of(non_null(:goal))), description: "Can be empty only in draft state" do
      resolve(&SplitTestResolver.goals/3)
    end

    field :finish_condition, :split_test_finish_condition, description: "Can be null only in draft state"

    field :traffic_percent, non_null(:integer)
    field :traffic_device_types, non_null(list_of(non_null(:device_type)))
    field :traffic_referrer_sources, non_null(list_of(non_null(:referrer_source)))

    field :conversion_reports, non_null(list_of(non_null(:split_test_conversion_report))) do
      arg(:goal_id, :uuid4, default_value: nil)
      resolve(&SplitTestResolver.conversion_reports/3)
    end
  end

  object :split_test_connection do
    field :nodes, non_null(list_of(non_null(:split_test)))
    field(:total_count, non_null(:integer))
  end

  object :split_test_page_category_queries do
    field :split_test_page_categories, non_null(list_of(non_null(:split_test_page_category))) do
      resolve(fn _parent, _ ->
        {:ok, Testly.SplitTests.get_page_categories()}
      end)
    end
  end

  object :split_test_page_type_queries do
    field :split_test_page_types, non_null(list_of(non_null(:split_test_page_type))) do
      resolve(fn _parent, _ ->
        {:ok, Testly.SplitTests.get_page_types()}
      end)
    end
  end

  object :split_test_queries do
    field :split_test, :split_test do
      arg(:id, non_null(:uuid4))
      resolve(&SplitTestResolver.split_test/3)
      # resolve(dataloader(SplitTests, SplitTest))
    end

    field :split_tests, non_null(:split_test_connection) do
      arg(:pagination, :pagination)
      arg(:filter, :split_test_filter)
      resolve(&SplitTestResolver.split_test_connection/3)
    end
  end

  object :split_test_mutations do
    field :create_split_test, :split_test_payload do
      arg(:split_test_params, non_null(:split_test_params))
      arg(:project_id, non_null(:uuid4))
      resolve(&SplitTestResolver.create_split_test/2)
      # middleware(&build_payload/2)
    end

    field :activate_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))
      resolve(&SplitTestResolver.activate_split_test/2)
    end

    field :pause_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))
      resolve(&SplitTestResolver.pause_split_test/2)
    end

    field :finish_split_test, :split_test do
      arg(:split_test_id, non_null(:uuid4))
      resolve(&SplitTestResolver.finish_split_test/2)
    end

    field :update_split_test, :split_test_payload do
      arg(:split_test_id, non_null(:uuid4))
      arg(:split_test_params, non_null(:split_test_params))
      resolve(&SplitTestResolver.update_split_test/2)
      middleware(&build_payload/2)
    end
  end
end
