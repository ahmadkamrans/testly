defmodule Testly.Heatmaps.SnapshotQuery do
  import Ecto.Query

  alias Testly.Heatmaps.{Snapshot}

  def from_snapshot do
    from(s in Snapshot, as: :snapshot)
  end

  def where_device_type(query, device_type) do
    where(query, [snapshot: s], s.device_type == ^device_type)
  end

  def where_page_id(query, page_id) do
    where(query, [snapshot: s], s.page_id == ^page_id)
  end

  def preload_assocs(query) do
    preload(query, [:views])
  end
end
