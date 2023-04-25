defmodule Testly.Heatmaps.ElemenTest do
  use ExUnit.Case, async: true

  alias Testly.Heatmaps.{Element, ClickPoint}

  describe "group_elements/1" do
    test "works" do
      click_points = [
        %ClickPoint{percent_x: 1.00, percent_y: 1.00, count: 1},
        %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 2},
        %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 3}
      ]

      elements = [
        %Element{
          selector: "body",
          click_points: click_points
        },
        %Element{
          selector: "div",
          click_points: click_points
        },
        %Element{
          selector: "body",
          click_points: click_points
        }
      ]

      response = Element.group_elements(elements)

      assert [
               %Element{
                 selector: "body",
                 click_points: [
                   %ClickPoint{percent_x: 1.00, percent_y: 1.00, count: 2},
                   %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 4},
                   %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 6}
                 ]
               },
               %Element{
                 selector: "div",
                 click_points: [
                   %ClickPoint{percent_x: 1.00, percent_y: 1.00, count: 1},
                   %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 2},
                   %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 3}
                 ]
               }
             ] = response
    end

    test "empty array" do
      assert [] = Element.group_elements([])
    end
  end

  @tag :performance
  describe "performace - group_elements/1" do
    setup do
      click_points = for i <- 1..10_000, do: %ClickPoint{percent_x: i, percent_y: i, count: i}

      els =
        for _i <- 1..1_000,
            do: %Element{
              selector: "body[#{Enum.random(0..50)}]",
              click_points: Enum.take_random(click_points, 20)
            }

      %{els: els}
    end

    test "works fast", %{els: els} do
      test_pid = self()

      spawn_link(fn ->
        Element.group_elements(els)
        |> Enum.count()

        send(test_pid, :ok)
      end)

      assert_receive :ok, 3_000
    end
  end
end
