defmodule Testly.Heatmaps.SnapshotQuery do
  import Ecto.Query

  alias Testly.Heatmaps.{Snapshot, View}

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
    one_week_ago = Timex.subtract(Timex.now(), Timex.Duration.from_days(7))

    view_query = from(v in View, where: v.visited_at >= ^one_week_ago)

    preload(query, views: ^view_query)
  end
end
