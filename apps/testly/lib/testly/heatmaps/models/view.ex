defmodule Testly.Heatmaps.View do
  use Testly.Schema

  alias Testly.Heatmaps.{Snapshot, Element}

  schema "heatmap_views" do
    belongs_to :snapshot, Snapshot
    field :session_recording_page_id, Ecto.UUID
    field :visited_at, :utc_datetime_usec
    embeds_many :elements, Element
  end
end
