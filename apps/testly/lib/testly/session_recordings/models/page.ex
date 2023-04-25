defmodule Testly.SessionRecordings.Page do
  use Testly.Schema

  alias __MODULE__
  alias Ecto.UUID
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.SessionEvents
  alias Testly.SessionEvents.{PageVisitedEvent}

  @type t :: %Page{
          id: Testly.Schema.pk(),
          session_recording_id: Testly.Schema.pk(),
          url: String.t(),
          title: String.t(),
          duration: integer(),
          clicks_count: integer(),
          visited_at: DateTime.t()
        }

  schema "session_recording_pages" do
    belongs_to :session_recording, SessionRecording

    field :title, :string
    field :url, :string
    field :duration, :integer, default: 0
    field :clicks_count, :integer, default: 0
    field :visited_at, :utc_datetime_usec
  end

  def to_entry(page) do
    Map.take(page, [:id, :session_recording_id, :title, :url, :duration, :clicks_count, :visited_at])
  end

  def changesets(grouped_events, session_recording_id, last_page) do
    grouped_events
    |> generate_changesets(session_recording_id, last_page)
  end

  defp generate_changesets(grouped_events, session_recording_id, last_page) do
    grouped_events = Enum.with_index(grouped_events)

    for {events, key} <- grouped_events do
      finish_duration_datetime =
        case Enum.at(grouped_events, key + 1) do
          nil -> List.last(events).happened_at
          {next_events, _} -> hd(next_events).happened_at
        end

      case hd(events) do
        %PageVisitedEvent{data: %PageVisitedEvent.Data{url: url, title: title}, happened_at: happened_at} ->
          change(%Page{}, %{
            id: UUID.generate(),
            session_recording_id: session_recording_id,
            url: url,
            title: title,
            duration: calculate_duration(List.first(events).happened_at, finish_duration_datetime),
            clicks_count: SessionEvents.calculate_clicks(events),
            visited_at: happened_at
          })

        _event ->
          change(last_page, %{
            duration: calculate_duration(last_page.visited_at, finish_duration_datetime),
            clicks_count: last_page.clicks_count + SessionEvents.calculate_clicks(events)
          })
      end
    end
  end

  defp calculate_duration(from, to) do
    Timex.diff(to, from, :milliseconds)
  end
end
