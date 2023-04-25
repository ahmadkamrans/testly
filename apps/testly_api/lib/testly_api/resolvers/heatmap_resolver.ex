defmodule TestlyAPI.HeatmapResolver do
  use TestlyAPI.Resolver

  alias Testly.Heatmaps
  alias Testly.Projects.Project

  def snapshot(page, %{device_type: device_type}, _res) do
    instrument("Heatmaps.get_snapshot", "Calculating snapshot", fn ->
      {:ok, Heatmaps.get_snapshot(page, device_type)}
    end)
  end

  def heatmap_pages(project, %{pagination: pagination, filter: filter, order: order}, _resolution) do
    {:ok,
     %{
       nodes: Heatmaps.get_pages(project, pagination: pagination, filter: filter, order: order),
       total_count: Heatmaps.get_pages_count(%Project{id: project.id})
     }}
  end

  def heatmap_page(%Project{} = _project, %{id: id}, _res) do
    {:ok, Heatmaps.get_page(id)}
  end
end
