defmodule Testly.Heatmaps.Page do
  use Testly.Schema

  alias Testly.Heatmaps.{Snapshot}

  schema "heatmap_pages" do
    has_many :snapshots, Snapshot
    has_one :snapshot, Snapshot
    field :project_id, Ecto.UUID
    field :url, :string

    # we populate this field with %ViewsCount{} on read
    field :views_count, :map, virtual: true
    field :clicks_count, :integer, virtual: true
    timestamps()
  end
end
