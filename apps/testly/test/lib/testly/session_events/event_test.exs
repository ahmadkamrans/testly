defmodule Testly.SessionEvents.EventTest do
  use Testly.DataCase
  import Testly.DataFactory

  alias Testly.SessionEvents.{Event, MouseMovedEvent}

  describe "to_event/1" do
    test "works" do
      event_schema = build(:mouse_moved_event_schema)

      assert %MouseMovedEvent{} = Event.to_event(event_schema)
    end
  end
end
