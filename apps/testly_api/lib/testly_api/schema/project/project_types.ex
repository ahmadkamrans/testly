defmodule TestlyAPI.Schema.ProjectTypes do
  use TestlyAPI.Schema.Notation
  alias TestlyAPI.ProjectResolver

  enum(:project_state,
    values: [
      :active,
      :waiting_for_first_visit,
      :code_may_not_be_installed
    ]
  )

  object :project do
    field(:id, non_null(:uuid4))
    field(:domain, non_null(:string))
    field(:is_recording_enabled, non_null(:boolean))

    field :state, non_null(:project_state) do
      resolve(&ProjectResolver.project_state/3)
    end

    import_fields(:goal_queries)
    import_fields(:heatmap_queries)
    import_fields(:session_recording_queries)
    import_fields(:split_test_queries)
    import_fields(:feedback_poll_queries)
  end

  object :projects_connection do
    field :nodes, non_null(list_of(non_null(:project)))
    field :total_count, non_null(:integer)
  end

  payload_object(:project_payload, :project)

  input_object :project_params do
    field(:domain, :string)
    field(:is_recording_enabled, :boolean, default_value: true)
  end

  object :project_queries do
    field :relevant_project, :project do
      resolve(&ProjectResolver.relevant_project/3)
    end

    field :projects, non_null(:projects_connection) do
      resolve(&ProjectResolver.projects/3)
    end

    field :project, :project do
      arg(:id, non_null(:uuid4))
      resolve(&ProjectResolver.project/3)
    end
  end

  object :project_mutations do
    field :create_project, type: :project_payload do
      arg(:project_params, :project_params)
      resolve(&ProjectResolver.create_project/2)
      middleware(&build_payload/2)
    end

    field :delete_project, :project do
      arg(:id, non_null(:uuid4))
      resolve(&ProjectResolver.delete_project/2)
    end

    field :update_project, :project_payload do
      arg(:id, non_null(:uuid4))
      arg(:project_params, :project_params)
      resolve(&ProjectResolver.update_project/2)
      middleware(&build_payload/2)
    end
  end
end
