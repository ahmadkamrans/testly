defmodule Testly.SplitTests.FinishConditionDb do
  @moduledoc """
    Persitence model, don't expose it outside of the context
  """
  use Testly.Schema

  alias Testly.SplitTests.SplitTest
  alias Testly.SplitTests.FinishConditionTypeEnum
  # alias Testly.SplitTests.{VisitsFinishCondition, DaysPassedFinishCondition, GoalConversionsFinishCondition}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk()
        }

  schema "split_test_finish_conditions" do
    belongs_to :split_test, SplitTest
    field :type, FinishConditionTypeEnum
    field :count, :integer
    field :goal_id, Ecto.UUID
  end

  @spec changeset(FinishConditionDb.t(), FinishCondition.t()) :: Changeset.t()
  def changeset(schema, finish_condition) do
    params = Map.from_struct(finish_condition)

    schema
    |> cast(params, [:id, :split_test_id, :type, :count, :goal_id])
  end
end
