defmodule Testly.SplitTests.FinishCondition do
  @moduledoc """
    Persitence model, don't expose it outside of the context
  """
  use Testly.Schema

  alias Testly.SplitTests.{
    SplitTest,
    FinishConditionTypeEnum
  }

  @type t :: %__MODULE__{
          id: Testly.Schema.pk()
        }

  schema "split_test_finish_conditions" do
    belongs_to :split_test, SplitTest
    field :type, FinishConditionTypeEnum
    field :count, :integer
    field :goal_id, Ecto.UUID
  end

  @spec changeset(FinishCondition.t(), map()) :: Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:type])
    |> type_changeset(params)
  end

  defp type_changeset(%Changeset{valid?: true} = changeset, params) do
    case Changeset.get_field(changeset, :type) do
      type when type in [:visits, :days_passed] ->
        changeset
        |> cast(params, [:count])
        |> validate_required([:count])
        |> validate_number(:count, greater_than_or_equal_to: 1)

      :goal_conversions ->
        changeset
        |> cast(params, [:count, :goal_id])
        |> validate_required([:count, :goal_id])
        |> validate_number(:count, greater_than_or_equal_to: 1)
    end
  end

  defp type_changeset(%Changeset{valid?: false} = changeset, _params), do: changeset

  # def check(%FinishCondition{count: count}, created_at) do
  #   Timex.diff(DateTime.utc_now(), created_at, :days) >= count
  # end

  # def check(
  #       %SplitTest{finish_condition: %GoalConversionsFinishCondition{count: count}},
  #       conversions_count
  #     ) do
  #   conversions_count >= count
  # end

  # def check(%SplitTest{finish_condition: %VisitsFinishCondition{count: count}}, visits_count) do
  #   visits_count >= count
  # end
end
