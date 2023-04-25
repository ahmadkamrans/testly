defmodule Testly.Heatmaps.ClickPoint do
  use Testly.Schema

  alias __MODULE__

  @type t :: %__MODULE__{
          percent_x: float(),
          percent_y: float(),
          count: integer()
        }

  @primary_key false
  embedded_schema do
    field :percent_x, :float
    field :percent_y, :float
    field :count, :integer
  end

  @spec group_click_points([ClickPoint.t()]) :: [ClickPoint.t()]
  def group_click_points(click_points) do
    click_points
    |> Enum.reduce(%{}, fn point, reduced_points ->
      key = "#{point.percent_x}_#{point.percent_y}"
      acc_point = Map.get(reduced_points, key, %ClickPoint{count: 0})

      Map.put(reduced_points, key, %ClickPoint{point | count: acc_point.count + point.count})
    end)
    |> Map.values()
  end

  @spec count_clicks([ClickPoint.t()]) :: number()
  def count_clicks(click_points) do
    for click_point <- click_points, reduce: 0 do
      acc -> acc + click_point.count
    end
  end
end
