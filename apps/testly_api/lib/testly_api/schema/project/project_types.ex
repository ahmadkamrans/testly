defmodule TestlyAPI.Schema.ProjectTypes do
  use Absinthe.Schema.Notation

  alias Testly.SessionRecordings
  alias Testly.Projects.Project

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
      resolve(fn %Project{id: project_id, created_at: created_at} = _project, _args, _resolution ->
        records_count = SessionRecordings.get_project_session_recordings_count(project_id)

        {:ok,
         case({records_count, Timex.diff(Timex.now(), created_at, :hours) > 1}) do
           {0, true} -> :code_may_not_be_installed
           {0, false} -> :waiting_for_first_visit
           _ -> :active
         end}
      end)
    end

    import_fields(:goal_queries)
    import_fields(:heatmap_queries)
    import_fields(:session_recording_queries)
    import_fields(:split_test_queries)
    import_fields(:feedback_poll_queries)
  end
end
