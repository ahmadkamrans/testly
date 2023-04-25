defmodule TestlyAPI.Schema.SessionRecordingType do
  use Absinthe.Schema.Notation

  alias Testly.Presence
  alias Testly.SessionEvents
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.SplitTests
  alias Testly.{Authorizer, SessionRecordings}
  alias Testly.Feedback
  alias Testly.Projects.Project
  alias Testly.SessionRecordings.Filter, as: SessionRecordingsFilter

  # Testly.SessionRecordings.ReferrerSourceEnum.__enum_map__()
  enum(:referrer_source,
    values: [
      :social,
      :search,
      :paid,
      :email,
      :direct,
      :unknown
    ]
  )

  input_object :session_recording_filter do
    field :converted_project_goal_ids_in, list_of(non_null(:uuid4))
    field :converted_split_test_goal_ids_in, list_of(non_null(:uuid4))
    field :created_at_gteq, :datetime
    field :created_at_lteq, :datetime
    field :duration_gteq, :integer
    field :duration_lteq, :integer
    field :location_country_iso_code_in, list_of(non_null(:string))
    field :device_type_in, list_of(non_null(:device_type))
    field :referrer_source_in, list_of(non_null(:referrer_source))
    field :split_test_id_eq, :uuid4
  end

  object :split_test_edge do
    field :node, non_null(:split_test) do
      resolve(fn %{split_test_id: split_test_id}, _args, _resolution ->
        {:ok, SplitTests.get_split_test(split_test_id)}
      end)
    end

    field :visited_variation, non_null(:split_test_variation)
    field :converted_goals, non_null(list_of(non_null(:goal)))
  end

  object :session_recording do
    field :id, non_null(:uuid4)
    field :referrer, :string
    field :referrer_source, non_null(:referrer_source)
    field :created_at, non_null(:datetime)
    field :project_id, non_null(:uuid4)
    field :location, non_null(:session_recording_location)
    field :device, non_null(:session_recording_device)
    field :duration, non_null(:integer)
    field :pages, non_null(list_of(non_null(:session_recording_page)))
    field :converted_project_goals, non_null(list_of(non_null(:goal)))

    field :feedback_poll_responses, non_null(list_of(non_null(:feedback_poll_response))) do
      resolve(fn session_recording, _args, _resolution ->
        {:ok, Feedback.get_responses(session_recording)}
      end)
    end

    field :split_test_edges, non_null(list_of(non_null(:split_test_edge))) do
      resolve(fn %SessionRecording{
                   split_test_goals: split_test_goals,
                   split_test_variations: split_test_variations
                 },
                 _args,
                 _resolution ->
        grouped_goals = Enum.group_by(split_test_goals, & &1.split_test_id)
        grouped_variations = Enum.group_by(split_test_variations, & &1.split_test_id)

        {:ok,
         for {split_test_id, [variation]} <- grouped_variations do
           %{
             split_test_id: split_test_id,
             visited_variation: variation,
             converted_goals: Map.get(grouped_goals, split_test_id, [])
           }
         end}
      end)
    end

    field :is_visitor_online, non_null(:boolean) do
      resolve(fn %SessionRecording{id: id}, _args, _resolution ->
        {:ok, !Enum.empty?(Presence.list("session_recording:#{id}"))}
      end)
    end

    field :events, non_null(list_of(non_null(:session_recording_event))) do
      resolve(fn %SessionRecording{id: id}, _args, _resolution ->
        {:ok, SessionEvents.get_raw_events(id)}
      end)
    end

    field :starting_page, non_null(:session_recording_page) do
      resolve(fn %SessionRecording{pages: pages}, _args, _resolution ->
        {:ok, List.first(pages)}
      end)
    end
  end

  object :session_recording_connection do
    field :nodes, non_null(list_of(non_null(:session_recording))) do
      resolve(fn %{
                   project_id: project_id,
                   page: page,
                   per_page: per_page,
                   filter: filter
                 },
                 _args,
                 _resolution ->
        {:ok,
         SessionRecordings.get_project_session_recordings(project_id,
           page: page,
           per_page: per_page,
           filter: filter
         )}
      end)
    end

    field(:total_records, non_null(:integer))

    field :avg_session_time, non_null(:integer) do
      resolve(fn %{project_id: _project_id}, _args, _resolution ->
        {:ok, 0}
      end)
    end

    field :avg_session_clicks, non_null(:integer) do
      resolve(fn %{project_id: _project_id}, _args, _resolution ->
        {:ok, 0}
      end)
    end
  end

  object :session_recording_queries do
    field :session_recordings, non_null(:session_recording_connection) do
      arg(:page, :integer, default_value: 1)
      arg(:per_page, :integer, default_value: 10)
      arg(:filter, :session_recording_filter)

      resolve(fn %Project{id: project_id} = _project, %{page: page, per_page: per_page} = args, _resolution ->
        filter = struct(SessionRecordingsFilter, args[:filter] || %{})

        {:ok,
         %{
           project_id: project_id,
           filter: filter,
           page: page,
           per_page: per_page,
           total_records: SessionRecordings.get_project_session_recordings_count(project_id, filter)
         }}
      end)
    end

    field :session_recording, :session_recording do
      arg(:id, non_null(:uuid4))

      resolve(fn %Project{} = project, %{id: id}, %{context: %{current_project_user: current_project_user}} ->
        with {:ok, %SessionRecording{} = session_recording} <- {:ok, SessionRecordings.get_session_recording(id)},
             :ok <- Authorizer.authorize(:show, session_recording, project, current_project_user),
             do: {:ok, session_recording}
      end)
    end
  end
end
