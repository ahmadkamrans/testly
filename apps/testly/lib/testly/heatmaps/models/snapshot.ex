defmodule Testly.Heatmaps.Snapshot do
  use Testly.Schema

  alias Testly.SessionRecordings.DeviceTypeEnum
  alias Testly.Heatmaps.{Page, View, Element}

  schema "heatmap_snapshots" do
    belongs_to :page, Page
    has_many :views, View
    field :device_type, DeviceTypeEnum
    field :doc_type, :string
    embeds_one :dom_nodes, Testly.SessionEvents.DOMNode, on_replace: :delete

    field :elements, {:array, Element}, virtual: true
  end
end
