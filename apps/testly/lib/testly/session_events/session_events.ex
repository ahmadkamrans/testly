defmodule Testly.SessionEvents do
  import Ecto.Query, only: [from: 2]

  require Logger

  alias Ecto.Changeset
  alias Testly.{Repo, SmartProxy}

  alias Testly.SessionRecordings.{Page}

  alias Testly.SessionEvents.{
    EventQuery,
    MouseClickedEvent,
    PageVisitedEvent,
    DOMMutatedEvent,
    Event,
    EventSchema,
    ProxyUrlReplacer
  }

  @stale_period_in_days 30

  @spec create_events(Testly.Schema.pk(), [map()]) :: :ok | {:error, [Changeset.t()]}
  def create_events(session_recording_id, events_params) do
    case Event.create_changesets(session_recording_id, events_params) do
      {:ok, changesets} ->
        events =
          changesets
          |> Enum.map(&Changeset.apply_changes/1)
          |> Enum.sort(fn event1, event2 ->
            case DateTime.compare(event1.happened_at, event2.happened_at) do
              :lt -> true
              _ -> false
            end
          end)

        # validate that there are no events older than persisted events
        # Repo.exists?(from(e in EventSchema, where: e.session_recording_id == ^session_recording_id))
        # oldest_event = Enum.min_by(event_entries, & &1.timestamp)
        # last_persisted_event = get_last_event(session_recording_id)

        EventQuery.from_event()
        |> EventQuery.where_session_recording_id(session_recording_id)
        |> Repo.exists?()
        |> case do
          true ->
            Repo.insert_all(EventSchema, Enum.map(events, &Event.to_entry/1), on_conflict: :nothing)

            :ok

          false ->
            case List.first(events) do
              %PageVisitedEvent{} ->
                Repo.insert_all(EventSchema, Enum.map(events, &Event.to_entry/1), on_conflict: :nothing)

                :ok

              _ ->
                {:error, :first_event_is_not_page_visited}
            end
        end

      {:error, _invalid_changesets} = error ->
        error
    end
  end

  @spec process_events([Page.t()], [[Event.t()]]) :: :ok
  # def process_events(unprocessed_events) do
  def process_events(pages, grouped_events) do
    pages
    |> Enum.zip(grouped_events)
    |> Enum.map(fn {page, page_events} ->
      page_events
      |> proxify_assets
      |> Enum.map(&Event.process_event(&1, page))
    end)
    |> List.flatten()
    |> Enum.chunk_every(20)
    |> Enum.each(fn chunked_events ->
      Repo.insert_all(
        EventSchema,
        Enum.map(chunked_events, &Event.to_entry/1),
        on_conflict: {:replace_all_except, [:id]},
        conflict_target: [:id]
      )
    end)

    :ok
  end

  defp proxify_assets(events) do
    Enum.map(events, fn event ->
      case event do
        %PageVisitedEvent{} = event ->
          ProxyUrlReplacer.replace_for(
            event,
            &SmartProxy.replace_css_urls(&1 || "", event.session_recording_id, event.data.origin),
            &SmartProxy.generate_url(event.session_recording_id, &1, event.data.origin)
          )

        %DOMMutatedEvent{} = event ->
          ProxyUrlReplacer.replace_for(
            event,
            &SmartProxy.replace_css_urls(&1 || "", event.session_recording_id, event.data.origin),
            &SmartProxy.generate_url(event.session_recording_id, &1, event.data.origin)
          )

        event ->
          event
      end
    end)
  end

  def get_events(%Testly.SessionRecordings.Page{id: page_id}) do
    EventQuery.from_event()
    |> EventQuery.where_page_id(page_id)
    |> EventQuery.where_processed()
    |> EventQuery.order_by_happened_at_asc()
    |> Repo.all()
    |> Enum.map(&Event.to_event/1)
  end

  @spec get_events(Testly.Schema.pk()) :: [Event.t()]
  def get_events(session_recording_id) do
    EventQuery.from_event()
    |> EventQuery.where_session_recording_id(session_recording_id)
    |> EventQuery.where_processed()
    |> EventQuery.order_by_happened_at_asc()
    |> Repo.all()
    |> Enum.map(&Event.to_event/1)
  end

  def get_unprocessed_events(session_recording_id) do
    EventQuery.from_event()
    |> EventQuery.where_session_recording_id(session_recording_id)
    |> EventQuery.where_not_processed()
    |> EventQuery.order_by_happened_at_asc()
    |> Repo.all()
    |> Enum.map(&Event.to_event/1)
  end

  @spec get_raw_events(Testly.Schema.pk()) :: [map()]
  def get_raw_events(session_recording_id) do
    EventQuery.from_event()
    |> EventQuery.where_session_recording_id(session_recording_id)
    |> EventQuery.where_processed()
    |> EventQuery.order_by_happened_at_asc()
    |> EventQuery.select_raw_map()
    |> Repo.all()
  end

  def calculate_clicks([]), do: 0

  def calculate_clicks(events) do
    Enum.count(events, &match?(%MouseClickedEvent{}, &1))
  end

  def get_not_processed_session_recording_ids(limit: limit, except_ids: except_ids) do
    limited_events =
      from(
        e in EventSchema,
        where: e.is_processed == false,
        where: not (e.session_recording_id in ^except_ids),
        limit: 10_000
      )

    from(
      e in Ecto.Query.subquery(limited_events),
      limit: ^limit,
      group_by: e.session_recording_id,
      select: e.session_recording_id
    )
    |> Repo.all(timeout: 120_000)
  end

  def group_events_by_page_visited(events) do
    events
    |> Enum.reduce([[]], &calculate_page_visited_group/2)
    |> List.delete([])
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.reverse()
  end

  def delete_recordings(recording_ids) do
    {deleted_count, _} =
      from(e in EventSchema, where: e.id in ^recording_ids)
      |> Repo.delete_all()

    deleted_count
  end

  def get_staled_event_ids(limit: limit) do
    staled_time = Timex.shift(DateTime.utc_now(), days: -@stale_period_in_days)

    from(e in EventSchema, where: e.happened_at < ^staled_time, select: e.id, limit: ^limit)
    |> Repo.all()
  end

  defp calculate_page_visited_group(%PageVisitedEvent{} = event, grouped_events) do
    [[event] | grouped_events]
  end

  defp calculate_page_visited_group(event, grouped_events) do
    head = [event | hd(grouped_events)]
    [head | tl(grouped_events)]
  end
end
