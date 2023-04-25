defmodule Testly.Goals.ProjectGoal do
  @moduledoc """
    Persitence model, don't expose it outside of the context
  """
  use Testly.Schema
  import Ecto.Query

  alias __MODULE__
  alias Testly.Goals.{Goal, GoalTypeEnum, ProjectGoalConversion}

  @type t :: %__MODULE__{
    id: Testly.Schema.pk(),
    project_id: Testly.Schema.pk(),
    name: String.t(),
    value: float(),
    path: [map()],
    type: GoalTypeEnum.t(),
    created_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  schema "project_goals" do
    has_many :conversions, ProjectGoalConversion
    field :project_id, Ecto.UUID
    field :name, :string
    field :value, :decimal
    field :type, GoalTypeEnum
    field :path, {:array, :map}
    timestamps()
  end

  def from_goals do
    from(g in ProjectGoal, as: :project_goal)
  end

  def where_project_id(query, project_id) do
    where(query, [project_goal: g], g.project_id == ^project_id)
  end

  def order_by_created_at_desc(query) do
    order_by(query, [project_goal: g], desc: g.created_at)
  end

  @spec changeset(ProjectGoal.t(), Goal.t()) :: Changeset.t()
  def changeset(schema, goal) do
    params = Map.from_struct(goal)

    schema
    |> Map.put(:project_id,  goal.assoc_id)
    |> cast(params, [:id, :name, :value, :created_at, :updated_at, :type, :path])
  end
end
