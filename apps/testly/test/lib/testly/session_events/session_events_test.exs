defmodule Testly.SessionEventsTest do
  use Testly.DataCase

  alias Testly.SessionEvents
  alias Testly.SessionEvents.{PageVisitedEvent, MouseClickedEvent}

  describe "group_events_by_page_visited/1" do
    test "works" do
      events = [
        %PageVisitedEvent{data: %PageVisitedEvent.Data{url: "http://test.com"}},
        %MouseClickedEvent{data: %MouseClickedEvent.Data{x: 5, y: 5, selector: ".test"}},
        %PageVisitedEvent{data: %PageVisitedEvent.Data{url: "http://test.com"}},
        %MouseClickedEvent{data: %MouseClickedEvent.Data{x: 5, y: 5, selector: ".test"}}
      ]

      response = SessionEvents.group_events_by_page_visited(events)

      assert [
               [%PageVisitedEvent{}, %MouseClickedEvent{}],
               [%PageVisitedEvent{}, %MouseClickedEvent{}]
             ] = response
    end
  end

  describe "#create_events/2" do
    setup :insert_data

    test "valid", %{session_recording: session_recording} do
      params = [
        build(:page_visited_event_params)
      ]

      assert SessionEvents.create_events(session_recording.id, params) === :ok

      assert [
               %PageVisitedEvent{}
             ] = SessionEvents.get_unprocessed_events(session_recording.id)
    end

    test "sorts by happened_at correctly", %{session_recording: session_recording} do
      params = [
        build(:mouse_moved_event_params, %{"timestamp" => 5}),
        build(:page_visited_event_params, %{"timestamp" => 3}),
        build(:mouse_moved_event_params, %{"timestamp" => 6}),
        build(:mouse_moved_event_params, %{"timestamp" => 1_000}),
        build(:mouse_moved_event_params, %{"timestamp" => 10_000})
      ]

      assert SessionEvents.create_events(session_recording.id, params) === :ok
    end

    test "error - first_event_is_not_page_visited", %{session_recording: session_recording} do
      params = [
        build(:page_visited_event_params, %{"timestamp" => 5}),
        build(:mouse_moved_event_params, %{"timestamp" => 3})
      ]

      response = SessionEvents.create_events(session_recording.id, params)

      assert {:error, :first_event_is_not_page_visited} = response
    end

    test "invalid", %{session_recording: session_recording} do
      params = [%{"type" => "page_visited"}]

      response = SessionEvents.create_events(session_recording.id, params)

      assert {:error, [%Changeset{}]} = response
    end

    test "inserts with duplicated events", %{session_recording: session_recording} do
      page_visited_event_params = build(:page_visited_event_params)
      events1 = [page_visited_event_params]
      events2 = [page_visited_event_params]

      assert SessionEvents.create_events(session_recording.id, events1) === :ok
      assert SessionEvents.create_events(session_recording.id, events2) === :ok

      assert [%PageVisitedEvent{}] = SessionEvents.get_unprocessed_events(session_recording.id)
    end
  end

  describe "#get_events/1" do
    setup :insert_data

    test "session_recording_id", %{session_recording: session_recording} do
      insert(:mouse_clicked_event_schema, session_recording_id: session_recording.id)

      response = SessionEvents.get_events(session_recording.id)

      assert [%MouseClickedEvent{}] = response
    end
  end

  defp insert_data(_context) do
    %{id: project_id} = insert(:project)
    session_recording = insert(:session_recording, project_id: project_id)

    %{session_recording: session_recording}
  end
end
