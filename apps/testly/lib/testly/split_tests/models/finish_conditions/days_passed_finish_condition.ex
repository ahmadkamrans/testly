defmodule Testly.SplitTests.DaysPassedFinishCondition do
  use Testly.SplitTests.FinishCondition

  finish_condition_schema do
    field :type, FinishConditionTypeEnum, default: :days_passed
    field :count, :integer
  end

  @impl true
  def changeset(schema, params) do
    schema
    |> cast(params, [:count])
    |> validate_required([:count])
    |> validate_number(:count, greater_than_or_equal_to: 1)
  end

  @impl true
  def cast_fields(changeset, params) do
    changeset
    |> cast(params, [:count])
  end
end
