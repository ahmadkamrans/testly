defmodule Testly.Goals.SplitTestGoal do
  @moduledoc """
    Persitence model, don't expose it outside of the context
  """
  use Testly.Schema
  import Ecto.Query

  alias __MODULE__
  alias Testly.Goals.{GoalTypeEnum, SplitTestGoalConversion}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          split_test_id: Testly.Schema.pk(),
          name: String.t(),
          value: float(),
          path: [map()],
          type: GoalTypeEnum.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "split_test_goals" do
    has_many :conversions, SplitTestGoalConversion
    field :split_test_id, Ecto.UUID
    field :name, :string
    field :value, :decimal
    field :type, GoalTypeEnum
    field :path, {:array, :map}
    field :index, :integer
    timestamps()
  end

  def from_goals do
    from(g in SplitTestGoal, as: :split_test_goal)
  end

  def where_split_test_id(query, split_test_id) do
    where(query, [split_test_goal: g], g.split_test_id == ^split_test_id)
  end

  def order_by_index(query) do
    order_by(query, [split_test_goal: g], asc: g.index)
  end

  @spec changeset(SplitTestGoal.t(), Goal.t()) :: Changeset.t()
  def changeset(schema, goal) do
    params = Map.from_struct(goal)

    schema
    |> Map.put(:split_test_id, goal.assoc_id)
    |> cast(params, [:id, :name, :value, :created_at, :updated_at, :type, :path, :index])
  end
end
