defmodule Testly.SplitTests.GoalConversionsFinishCondition do
  use Testly.SplitTests.FinishCondition

  finish_condition_schema do
    field :type, FinishConditionTypeEnum, default: :goal_conversions
    field :count, :integer
    field :goal_id, Ecto.UUID
  end

  @impl true
  def changeset(schema, params) do
    # TODO: Validate goal_conversions_goal_id is within split test
    schema
    |> cast(params, [:count, :goal_id])
    |> validate_required([:count, :goal_id])
    |> validate_number(:count, greater_than_or_equal_to: 1)
  end

  @impl true
  def cast_fields(changeset, params) do
    changeset
    |> cast(params, [:count, :goal_id])
  end
end
