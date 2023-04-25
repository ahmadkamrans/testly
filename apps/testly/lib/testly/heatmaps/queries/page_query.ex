defmodule Testly.Heatmaps.PageQuery do
  import Ecto.Query

  alias Testly.Heatmaps.{Page, ViewsCount}

  def from_page do
    from(p in Page, as: :page)
  end

  def select_distinct(query) do
    distinct(query, true)
  end

  def join_snapshot(query) do
    from([page: p] in query, join: s in assoc(p, :snapshots), as: :snapshot)
  end

  def join_view(query) do
    from([snapshot: s] in query, join: v in assoc(s, :views), as: :view)
  end

  def preload_assocs(query, snapshot_query) do
    preload(query, snapshot: ^snapshot_query)
  end

  def order_by_field(query, direction, field) do
    order_by(query, [page: p], [{^direction, ^field}])
  end

  def order_by_total_views_count(query, direction) do
    order_by(query, [view: v], [{^direction, count(v.id)}])
  end

  def where_views_one_week_old(query) do
    one_week_ago = Timex.subtract(Timex.now(), Timex.Duration.from_days(7))

    from([view: v] in query, where: v.visited_at >= ^one_week_ago)
  end

  def where_project_id(query, value) do
    from([page: p] in query, where: p.project_id == ^value)
  end

  def where_url_contains(query, value) do
    from([page: p] in query, where: ilike(p.url, ^"%#{value}%"))
  end

  def select_views_count(query) do
    select_merge(query, [page: p, snapshot: s, view: v], %{
      views_count: %ViewsCount{
        total: count(v.id),
        desktop: fragment("count(?) FILTER (WHERE ?  = ?)", v.id, s.device_type, "desktop"),
        mobile: fragment("count(?) FILTER (WHERE ? = ?)", v.id, s.device_type, "mobile"),
        tablet: fragment("count(?) FILTER (WHERE ? = ?)", v.id, s.device_type, "tablet")
      }
    })
    |> group_by([page: p], [p.id])
  end
end
