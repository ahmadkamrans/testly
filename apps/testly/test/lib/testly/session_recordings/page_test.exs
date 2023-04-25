defmodule Testly.SessionRecordings.PageTest do
  # TODO: FIX ME
  # use Testly.DataCase
  # import Testly.DataFactory

  # alias Ecto.Changeset
  # alias Testly.SessionRecordings.{Page}

  # alias Testly.SessionEvents.PageVisitedEvent

  # describe "changesets/2" do
  #   test "works" do
  #     first_url_happened_at = DateTime.utc_now()
  #     second_url_happened_at = Timex.shift(DateTime.utc_now(), hours: 4)

  #     events = [
  #       %PageVisitedEvent{data: %UrlChangedEvent.Data{url: "http://test.com"}, happened_at: first_url_happened_at},

  #       build(:page_visited_event_schema, happened_at: first_url_happened_at),
  #       build(:mouse_clicked_event, happened_at: first_url_happened_at),
  #       build(:mouse_clicked_event, happened_at: Timex.shift(first_url_happened_at, hours: 4)),
  #       %PageVisitedEvent{data: %UrlChangedEvent.Data{url: "http://test.com"}, happened_at: second_url_happened_at},
  #       build(:mouse_clicked_event, happened_at: second_url_happened_at),
  #       build(:mouse_clicked_event, happened_at: Timex.shift(second_url_happened_at, hours: 4))
  #     ]

  #     changesets = Page.changesets(events, "session recording id")

  #     assert [%Changeset{}, %Changeset{}] = changesets

  #     time = Timex.Duration.from_hours(4) |> Timex.Duration.to_milliseconds(truncate: true)
  #     assert %{duration: ^time} = hd(changesets).changes
  #   end
  # end
end
