defmodule Testly.SessionEventsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.SessionEvents.{
        EventSchema,
        MouseClickedEvent,
        MouseMovedEvent,
        PageVisitedEvent
      }

      def page_visited_event_factory do
        %PageVisitedEvent{
          type: :page_visited,
          data: %PageVisitedEvent.Data{
            url: "http://example.com/",
            title: "Title",
            origin: "http://example.com/",
            doc_type: "<!DOCTYPE html>",
            dom_snapshot: %{id: 1, node_type: 1}
          }
        }
        |> put_common_event_schema_fields
      end

      def mouse_clicked_event_factory do
        %MouseClickedEvent{
          type: :mouse_clicked,
          data: %MouseClickedEvent.Data{
            x: 1,
            y: 1,
            percent_x: 1.00,
            percent_y: 1.00,
            selector: "selector"
          }
        }
        |> put_common_event_schema_fields
      end

      def page_visited_event_schema_factory do
        %EventSchema{
          type: :page_visited,
          data: %{
            url: "http://example.com/",
            title: "Title",
            origin: "http://example.com/",
            dom_snapshot: %{id: 1, node_type: 1}
          }
        }
        |> put_common_event_schema_fields
      end

      def dom_mutated_event_schema_factory do
        %EventSchema{
          type: :dom_mutated,
          data: %{
            origin: "example.com",
            attributes: [%{id: 123, name: "test"}]
          }
        }
        |> put_common_event_schema_fields
      end

      def scrolled_event_schema_factory do
        %EventSchema{
          type: :scrolled,
          data: %{
            top: 1,
            left: 1,
            id: 1
          }
        }
        |> put_common_event_schema_fields
      end

      def window_resized_event_schema_factory do
        %EventSchema{
          type: :window_resized,
          data: %{
            height: 1,
            width: 1
          }
        }
        |> put_common_event_schema_fields
      end

      def mouse_clicked_event_schema_factory do
        %EventSchema{
          type: :mouse_clicked,
          data: %{
            x: 1,
            y: 1,
            percent_x: 1.00,
            percent_y: 1.00,
            selector: "selector"
          }
        }
        |> put_common_event_schema_fields
      end

      def mouse_moved_event_schema_factory do
        %EventSchema{
          type: :mouse_moved,
          data: %{
            x: 1,
            y: 1
          }
        }
        |> put_common_event_schema_fields
      end

      def page_visited_event_params_factory do
        %{
          "type" => "page_visited",
          "data" => %{
            "doc_type" => "<!DOCTYPE html>",
            "url" => "http://example.com/",
            "title" => "Title",
            "origin" => "http://example.com/",
            "dom_snapshot" => %{"id" => 1, "node_type" => 1}
          }
        }
        |> put_common_event_params
      end

      def mouse_clicked_event_params_factory do
        %{
          "type" => "mouse_clicked",
          "data" => %{
            "x" => 1,
            "y" => 1,
            "percent_x" => 1.00,
            "percent_y" => 1.00,
            "selector" => "selector"
          }
        }
        |> put_common_event_params
      end

      def mouse_moved_event_params_factory do
        %{
          "type" => "mouse_moved",
          "data" => %{
            "x" => 1,
            "y" => 1
          }
        }
        |> put_common_event_params
      end

      defp put_common_event_schema_fields(event_schema) do
        %{
          event_schema
          | happened_at: DateTime.utc_now(),
            is_processed: true
        }
      end

      defp put_common_event_params(event_params) do
        Map.merge(event_params, %{
          "timestamp" => DateTime.utc_now() |> DateTime.to_unix()
        })
      end
    end
  end
end
