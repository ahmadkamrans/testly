defmodule Testly.Goals.SplitTestGoalConversion do
  use Testly.Schema

  alias Testly.Goals.SplitTestGoal

  import Ecto.Query

  schema "split_test_goal_conversions" do
    belongs_to :split_test_goal, SplitTestGoal
    field(:split_test_variation_visit_id, Ecto.UUID)
    field(:happened_at, :utc_datetime_usec)
  end

  def from_goal_conversions do
    from(g in __MODULE__, as: :split_test_goal_conversion)
  end

  def where_project_goal(query, goal_id) do
    where(query, [split_test_goal_conversion: s_t_g_c], s_t_g_c.split_test_goal_id == ^goal_id)
  end
end
