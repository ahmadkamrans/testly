defmodule Testly.SessionRecordings do
  @moduledoc """
    Session Recordings Context Public API.
  """

  # @behaviour Testly.SessionRecordingsBehaviour

  alias Testly.SessionRecordings.{SessionRecording, Filter, Page}
  alias Testly.{Repo}
  import Ecto.Query, only: [from: 2]

  @stale_period_in_days 30

  @callback get_session_recording(String.t()) :: SessionRecording.t() | nil
  def get_session_recording(id) do
    query =
      from(s_r in SessionRecording,
        preload: [
          :location,
          :device,
          :converted_project_goals,
          :split_test_goals,
          :split_test_variations,
          pages: ^pages_query()
        ]
      )

    Repo.get(query, id)
  end

  @callback get_next_session_recording(String.t()) :: SessionRecording.t() | nil
  def get_next_session_recording(id) do
    current_session_recording = Repo.get!(SessionRecording, id)

    next_session_recording_query =
      from(
        s_r in SessionRecording,
        preload: [:location, :device],
        where: s_r.created_at < ^current_session_recording.created_at,
        where: s_r.project_id == ^current_session_recording.project_id,
        order_by: [desc: s_r.created_at],
        limit: 1
      )

    Repo.one(next_session_recording_query)
  end

  @callback get_previous_session_recording(String.t()) :: SessionRecording.t() | nil
  def get_previous_session_recording(id) do
    current_session_recording = Repo.get!(SessionRecording, id)

    previous_session_recording_query =
      from(
        s_r in SessionRecording,
        preload: [:location, :device],
        where: s_r.created_at > ^current_session_recording.created_at,
        where: s_r.project_id == ^current_session_recording.project_id,
        order_by: s_r.created_at,
        limit: 1
      )

    Repo.one(previous_session_recording_query)
  end

  @callback get_project_session_recordings(String.t(),
              page: non_neg_integer(),
              per_page: pos_integer(),
              filter: Filter.t()
            ) :: [SessionRecording.t()]
  def get_project_session_recordings(project_id, page: page, per_page: per_page, filter: filter) do
    from(s_r in Filter.filter(filter),
      where: s_r.project_id == ^project_id and s_r.is_ready == true,
      order_by: [desc: s_r.created_at],
      preload: [
        :location,
        :converted_project_goals,
        :split_test_goals,
        :split_test_variations,
        :device,
        pages: ^pages_query()
      ],
      limit: ^per_page,
      offset: ^((page - 1) * per_page),
      distinct: true
    )
    |> Repo.all()
  end

  @callback get_project_avg_session_recordings_duration(String.t()) :: integer()
  def get_project_avg_session_recordings_duration(project_id) do
    query =
      from(
        s_r in SessionRecording,
        where: s_r.project_id == ^project_id and s_r.is_ready == true
      )

    query
    |> Repo.aggregate(:avg, :duration)
    |> Kernel.||(Decimal.from_float(0.0))
    |> Decimal.to_float()
    |> trunc()
  end

  @callback get_project_avg_session_recordings_clicks_count(String.t()) :: integer()
  def get_project_avg_session_recordings_clicks_count(project_id) do
    query =
      from(
        s_r in SessionRecording,
        where: s_r.project_id == ^project_id and s_r.is_ready == true
      )

    query
    |> Repo.aggregate(:avg, :clicks_count)
    |> Kernel.||(Decimal.from_float(0.0))
    |> Decimal.to_float()
    |> trunc()
  end

  @callback get_project_session_recordings_count(String.t(), Filter.t()) :: integer()
  def get_project_session_recordings_count(project_id, filter \\ %Filter{}) do
    query =
      from(
        s_r in Filter.filter(filter),
        where: s_r.project_id == ^project_id and s_r.is_ready == true,
        distinct: true
      )

    query
    |> Repo.aggregate(:count, :id)
  end

  defp pages_query do
    from(e in Page, order_by: e.visited_at)
  end

  @callback create_session_recording(String.t(), map()) ::
              {:ok, SessionRecording.t()}
              | {:error, Ecto.Changeset.t()}
  def create_session_recording(project_id, params) do
    %SessionRecording{project_id: project_id}
    |> SessionRecording.create_changeset(params)
    |> Repo.insert()
  end

  def calculate_session_recording(session_recording) do
    pages = Repo.all(from(p in Page, where: p.session_recording_id == ^session_recording.id))
    duration = Enum.reduce(pages, 0, fn page, acc -> page.duration + acc end)
    clicks_count = Enum.reduce(pages, 0, fn page, acc -> page.clicks_count + acc end)
    is_ready = if duration > 0, do: true, else: false

    updates = [
      set: [
        duration: duration,
        clicks_count: clicks_count,
        is_ready: is_ready
      ]
    ]

    from(s_r in SessionRecording, where: s_r.id == ^session_recording.id)
    |> Repo.update_all(updates)

    {:ok, session_recording}
  end

  def calculate_pages(session_recording, grouped_events) do
    last_page = List.last(session_recording.pages)

    pages =
      grouped_events
      |> Page.changesets(session_recording.id, last_page)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    Repo.insert_all(Page, Enum.map(pages, &Page.to_entry/1),
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: [:session_recording_id, :visited_at]
    )

    {:ok, pages}
  end

  def delete_recordings(recording_ids) do
    {deleted_count, _} =
      from(s_r in SessionRecording, where: s_r.id in ^recording_ids)
      |> Repo.delete_all()

    deleted_count
  end

  def get_staled_recording_ids(limit: limit) do
    staled_time = Timex.shift(DateTime.utc_now(), days: -@stale_period_in_days)

    from(s_r in SessionRecording, where: s_r.created_at < ^staled_time, select: s_r.id, limit: ^limit)
    |> Repo.all()
  end
end
