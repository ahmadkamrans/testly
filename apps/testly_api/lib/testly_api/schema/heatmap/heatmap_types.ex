defmodule TestlyAPI.Schema.HeatmapTypes do
  use Absinthe.Schema.Notation

  alias TestlyAPI.HeatmapResolver

  enum(:heatmap_page_order_field,
    values: [
      :created_at,
      :total_views_count
    ]
  )

  input_object :heatmap_page_filter do
    field(:url_cont, non_null(:string))
  end

  input_object :heatmap_page_order do
    field(:direction, non_null(:order_direction))
    field(:field, non_null(:heatmap_page_order_field))
  end

  object :heatmap_page do
    field(:id, non_null(:uuid4))
    field(:url, non_null(:string))
    field(:views_count, non_null(:heatmap_views_count))
    field(:created_at, non_null(:datetime))

    field :snapshot, non_null(:heatmap_snapshot) do
      arg(:device_type, non_null(:device_type))
      resolve(&HeatmapResolver.snapshot/3)
    end
  end

  object :heatmap_views_count do
    field(:total, non_null(:integer))
    field(:desktop, non_null(:integer))
    field(:mobile, non_null(:integer))
    field(:tablet, non_null(:integer))
  end

  object :heatmap_snapshot do
    field(:device_type, non_null(:device_type))
    field(:doc_type, non_null(:string))
    field(:dom_nodes, non_null(:json))
    field(:elements, non_null(list_of(non_null(:heatmap_element))))
  end

  object :heatmap_element do
    field(:selector, non_null(:string))
    field(:click_points, non_null(list_of(non_null(:heatmap_click_point))))
  end

  object :heatmap_click_point do
    field(:percent_x, non_null(:integer))
    field(:percent_y, non_null(:integer))
    field(:count, non_null(:integer))
  end

  object :heatmap_page_connection do
    field(:nodes, non_null(list_of(non_null(:heatmap_page))))
    field(:total_count, non_null(:integer))
  end

  object :heatmap_queries do
    field :heatmap_pages, non_null(:heatmap_page_connection) do
      arg(:pagination, :pagination)
      arg(:filter, :heatmap_page_filter)
      arg(:order, :heatmap_page_order)
      resolve(&HeatmapResolver.heatmap_pages/3)
    end

    field :heatmap_page, non_null(:heatmap_page) do
      arg(:id, non_null(:uuid4))
      resolve(&HeatmapResolver.heatmap_page/3)
    end
  end
end
