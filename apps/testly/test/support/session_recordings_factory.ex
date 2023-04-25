defmodule Testly.SessionRecordingsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.SessionRecordings.{SessionRecording, Device, Location, Page}

      def session_recording_factory do
        %SessionRecording{
          location: %Location{},
          device: %Device{
            type: :desktop
          },
          duration: 1010,
          is_ready: true
        }
      end

      def session_recording_page_factory do
        %Page{
          title: "title",
          url: "http://example.com/",
          duration: 1000,
          visited_at: DateTime.utc_now()
        }
      end
    end
  end
end
