defmodule Testly.Goals.Conversion do
  use Testly.Schema

  alias Testly.Goals.{ProjectGoalConversion, SplitTestGoalConversion}

  embedded_schema do
    field :goal_id, Ecto.UUID
    field :assoc_id, Ecto.UUID
    field :happened_at, :utc_datetime_usec
  end

  def cast_fields(schema, %ProjectGoalConversion{} = project_goal_conversion) do
    change(schema, %{
      goal_id: project_goal_conversion.project_goal_id,
      assoc_id: project_goal_conversion.session_recording_id,
      happened_at: project_goal_conversion.happened_at
    })
  end

  def cast_fields(schema, %SplitTestGoalConversion{} = split_test_goal_conversion) do
    change(schema, %{
      goal_id: split_test_goal_conversion.split_test_goal_id,
      assoc_id: split_test_goal_conversion.split_test_variation_visit_id,
      happened_at: split_test_goal_conversion.happened_at
    })
  end
end
