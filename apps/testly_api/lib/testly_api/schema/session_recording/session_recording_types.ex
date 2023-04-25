defmodule TestlyAPI.Schema.SessionRecordingTypes do
  use Absinthe.Schema.Notation

  alias TestlyAPI.SessionRecordingResolver
  alias Testly.Presence
  alias Testly.SessionRecordings
  alias Testly.SessionRecordings.SessionRecording

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

  # Testly.SessionEvents.EventTypeEnum.__enum_map__()
  enum(:session_recording_event_type,
    values: [
      :mouse_clicked,
      :mouse_moved,
      :scrolled,
      :page_visited,
      :dom_mutated,
      :window_resized,
      :css_rule_inserted,
      :css_rule_deleted
    ]
  )

  # Testly.SessionRecordings.DeviceTypeEnum.__enum_map__()
  enum(:device_type,
    values: [
      :desktop,
      :mobile,
      :tablet
    ]
  )

  input_object :session_recording_filter do
    field(:converted_project_goal_ids_in, list_of(non_null(:uuid4)))
    field(:converted_split_test_goal_ids_in, list_of(non_null(:uuid4)))
    field(:created_at_gteq, :datetime)
    field(:created_at_lteq, :datetime)
    field(:duration_gteq, :integer)
    field(:duration_lteq, :integer)
    field(:location_country_iso_code_in, list_of(non_null(:string)))
    field(:device_type_in, list_of(non_null(:device_type)))
    field(:referrer_source_in, list_of(non_null(:referrer_source)))
    field(:split_test_id_eq, :uuid4)
  end

  object :session_recording_event do
    field :happened_at, non_null(:datetime)
    field :type, non_null(:session_recording_event_type)

    field :data, non_null(:json)
  end

  object :device_browser do
    field(:name, :string)
    field(:version, :string)
  end

  object :device_os do
    field(:name, :string)
    field(:version, :string)
  end

  object :session_recording_page do
    field :id, non_null(:uuid4)

    field :title, non_null(:string)
    field :url, non_null(:string)
    field :duration, non_null(:integer)
    field :visited_at, non_null(:datetime)
  end

  object :session_recording_device do
    field(:id, non_null(:uuid4))

    field(:user_agent, non_null(:string))
    field(:screen_height, non_null(:integer))
    field(:screen_width, non_null(:integer))
    field(:type, non_null(:device_type))

    field :browser, non_null(:device_browser) do
      resolve(&SessionRecordingResolvers.browser/3)
    end

    field :os, non_null(:device_os) do
      resolve(&SessionRecordingResolvers.os/3)
    end
  end

  object :session_recording_location do
    field :id, non_null(:uuid4)

    field :ip, non_null(:string)
    field :country, :string
    field :country_iso_code, :string
    field :city, :string
  end

  object :split_test_edge do
    field :node, non_null(:split_test) do
      resolve(&SessionRecordingResolver.split_test/3)
    end

    field(:visited_variation, non_null(:split_test_variation))
    field(:converted_goals, non_null(list_of(non_null(:goal))))
  end

  object :session_recording do
    field(:id, non_null(:uuid4))
    field(:referrer, :string)
    field(:referrer_source, non_null(:referrer_source))
    field(:created_at, non_null(:datetime))
    field(:project_id, non_null(:uuid4))
    field(:location, non_null(:session_recording_location))
    field(:device, non_null(:session_recording_device))
    field(:duration, non_null(:integer))
    field(:pages, non_null(list_of(non_null(:session_recording_page))))
    field(:converted_project_goals, non_null(list_of(non_null(:goal))))

    field :feedback_poll_responses, non_null(list_of(non_null(:feedback_poll_response))) do
      resolve(&SessionRecordingResolver.feedback_poll_responses/3)
    end

    field :split_test_edges, non_null(list_of(non_null(:split_test_edge))) do
      resolve(&SessionRecordingResolver.split_test_edges/3)
    end

    field :is_visitor_online, non_null(:boolean) do
      resolve(fn %SessionRecording{id: id}, _args, _resolution ->
        {:ok, !Enum.empty?(Presence.list("session_recording:#{id}"))}
      end)
    end

    field :events, non_null(list_of(non_null(:session_recording_event))) do
      resolve(&SessionRecordingResolver.events/3)
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

    field(:total_count, non_null(:integer))

    field :avg_session_time, non_null(:integer) do
      resolve(fn %{project_id: project_id}, _args, _resolution ->
        {:ok, SessionRecordings.get_project_avg_session_recordings_duration(project_id)}
      end)
    end

    field :avg_session_clicks, non_null(:integer) do
      resolve(fn %{project_id: project_id}, _args, _resolution ->
        {:ok, SessionRecordings.get_project_avg_session_recordings_clicks_count(project_id)}
      end)
    end
  end

  object :session_recording_queries do
    field :session_recordings, non_null(:session_recording_connection) do
      arg(:page, :integer, default_value: 1)
      arg(:per_page, :integer, default_value: 10)
      arg(:filter, :session_recording_filter)
      resolve(&SessionRecordingResolver.session_recordings/3)
    end

    field :session_recording, :session_recording do
      arg(:id, non_null(:uuid4))
      resolve(&SessionRecordingResolver.session_recording/3)
    end
  end
end
