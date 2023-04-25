defmodule Testly.Heatmaps.Element do
  use Testly.Schema

  alias __MODULE__
  alias Testly.Heatmaps.{ClickPoint}
  alias Testly.SessionEvents.{MouseClickedEvent}

  @type t :: %__MODULE__{
          selector: String.t(),
          click_points: [ClickPoint.t()]
        }

  @primary_key false
  embedded_schema do
    field :selector, :string
    embeds_many :click_points, ClickPoint
  end

  @spec group_elements(Enumerable.t()) :: Enumerable.t()
  def group_elements(elements) do
    reduced_elements =
      elements
      |> Enum.reduce(%{}, fn element, reduced_elements ->
        acc_element = Map.get(reduced_elements, element.selector, %Element{click_points: []})

        Map.put(
          reduced_elements,
          element.selector,
          Map.replace!(element, :click_points, acc_element.click_points ++ element.click_points)
        )
      end)

    batch_size = trunc(Enum.count(reduced_elements) / System.schedulers_online())
    batch_size = if(batch_size === 0, do: 1, else: batch_size)

    reduced_elements
    |> Stream.chunk_every(batch_size)
    |> Task.async_stream(fn batch_elements ->
      for {_, element} <- batch_elements do
        Map.replace!(element, :click_points, ClickPoint.group_click_points(element.click_points))
      end
    end)
    |> Enum.flat_map(fn {:ok, els} -> els end)
  end

  @spec mouse_clicked_events_to_elements([MouseClickedEvent.t()]) :: [Element.t()]
  def mouse_clicked_events_to_elements(events) do
    for event <- events do
      %Element{
        selector: event.data.selector,
        click_points: [
          %ClickPoint{
            percent_x: event.data.percent_x,
            percent_y: event.data.percent_y,
            count: 1
          }
        ]
      }
    end
  end
end
