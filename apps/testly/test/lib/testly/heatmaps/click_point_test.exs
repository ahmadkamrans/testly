defmodule Testly.Heatmaps.ClickPointTest do
  use Testly.DataCase

  alias Testly.Heatmaps.{ClickPoint}

  describe "group_click_points/1" do
    test "works" do
      click_points = [
        %ClickPoint{percent_x: 1.00, percent_y: 1.00, count: 1},
        %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 1},
        %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 1},
        %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 2},
        %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 1}
      ]

      response = ClickPoint.group_click_points(click_points)

      assert [
               %ClickPoint{percent_x: 1.00, percent_y: 1.00, count: 1},
               %ClickPoint{percent_x: 2.00, percent_y: 2.00, count: 2},
               %ClickPoint{percent_x: 3.00, percent_y: 3.00, count: 3}
             ] = response
    end
  end
end
