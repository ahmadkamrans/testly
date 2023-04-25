defmodule Testly.HeatmapsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Heatmaps.{
        Page,
        Snapshot,
        View
      }

      def heatmap_page_factory do
        %Page{
          url: sequence(:url, &"http://example.com/#{&1}")
        }
      end

      def heatmap_snapshot_factory do
        %Snapshot{
          device_type: :desktop
        }
      end

      def heatmap_view_factory do
        %View{
          visited_at: DateTime.utc_now()
        }
      end
    end
  end
end
