defmodule Testly.Goals.Goal do
  use Testly.Schema
  alias Testly.Goals.{PathGoal, GoalTypeEnum, Conversion, PathStep}

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

  schema "goals" do
    has_many :conversions, Conversion
    field :type, GoalTypeEnum
    field :project_id, Ecto.UUID
    field :name, :string
    field :value, :decimal, default: Decimal.from_float(0.0)
    # field :path, {:array, :map}
    embeds_many :path, PathStep, on_replace: :delete
    timestamps()
  end

  def create_changeset(schema, params) do
    schema
    |> cast(params, [:name, :value, :type])
    |> validate_required([:name, :value, :type])
    |> type_changeset(params)
  end

  def update_changeset(schema, params) do
    schema
    |> cast(params, [:name, :value])
    |> validate_required([:name, :value])
    |> type_changeset(params)
  end

  defp type_changeset(%Changeset{valid?: true} = changeset, params) do
    case Changeset.get_field(changeset, :type) do
      :path ->
        changeset
        |> cast_embed(:path, required: true)
    end
  end

  defp type_changeset(%Changeset{valid?: false} = changeset, _params) do
    changeset
  end

  def check_conversion(%Goal{type: :path} = goal, session_recording) do
    PathGoal.check_conversion(goal, session_recording)
  end

  # defmacro goal_schema(do: block) do
  #   quote do
  #     alias Testly.Goals.{Conversion}

  #     schema "goals" do
  #       has_many :conversions, Conversion
  #       field :project_id, Ecto.UUID
  #       field :name, :string
  #       field :value, :decimal, default: Decimal.from_float(0.0)
  #       timestamps()
  #       unquote(block)
  #     end

  #     @spec base_changeset(%__MODULE__{}, map) :: Changeset.t()
  #     defp base_changeset(schema, params) do
  #       schema
  #       |> cast(params, [:name, :value, :index])
  #       |> validate_required([:name])
  #     end

  #     def to_type_goal(%Goal{} = goal) do
  #       params = Map.from_struct(goal)

  #       struct(__MODULE__)
  #       |> cast(params, [:id, :project_id, :name, :value, :created_at, :updated_at])
  #       # |> cast_embed(:conversions, with: &Conversion.cast_fields/2)
  #       # |> cast_fields(params)
  #       |> Changeset.apply_changes()
  #     end
  #   end
  # end

  # defmacro __using__(_) do
  #   quote do
  #     use Testly.Schema
  #     alias Testly.Goals.GoalTypeEnum
  #     # @behaviour Testly.Goals.Goal
  #     import Testly.Goals.Goal, only: [goal_schema: 1]
  #   end
  # end

  # @spec create_changeset(String.t(), map()) :: Changeset.t()
  # def create_changeset(project_id, params) do
  #   module = type_to_module(params["type"] || params[:type])
  #   schema = struct(module, project_id: project_id)

  #   schema
  #   |> schema.__struct__.changeset(params)
  #   |> Map.put(:action, :insert)
  # end

  # @spec update_changeset(Goal.t(), map()) :: Changeset.t()
  # def update_changeset(schema, params) do
  #   schema
  #   |> schema.__struct__.changeset(params)
  #   |> Map.put(:action, :update)
  # end

  # @spec delete_changeset(Goal.t()) :: Changeset.t()
  # def delete_changeset(schema) do
  #   schema
  #   |> Changeset.change()
  #   |> Map.put(:action, :delete)
  # end

  # @spec changesets(String.t(), [Goal.t()], [map()]) :: {:ok, [Changeset.t()]} | {:error, [Changeset.t()]}
  # def changesets(assoc_id, goals, goals_params) do
  #   goals_params =
  #     goals_params
  #     |> Enum.with_index()
  #     |> Enum.map(fn {params, i} ->
  #       put_in(params[:index], i)
  #     end)

  #   update_changesets =
  #     for goal <- goals do
  #       case Enum.find(goals_params, &(&1[:id] == goal.id)) do
  #         nil -> delete_changeset(goal)
  #         goal_params -> update_changeset(goal, goal_params)
  #       end
  #     end

  #   create_changesets =
  #     for goal_params <- goals_params, goal_params[:id] == nil do
  #       changeset(assoc_id, goal_params)
  #       |> Map.put(:action, :insert)
  #     end

  #   changesets = update_changesets ++ create_changesets

  #   invalid_changesets = Enum.filter(changesets, &(&1.valid? == false))

  #   if Enum.empty?(invalid_changesets) do
  #     {:ok, changesets}
  #   else
  #     {:error, invalid_changesets}
  #   end
  # end

  # def to_type_goal(%Goal{} = goal) do
  #   type_to_module(goal.type).to_type_goal(goal)
  # end

  # defp type_to_module(type) do
  #   case @modules[to_string(type)] do
  #     nil -> raise "Unexpected Goal Type #{inspect(type)}"
  #     module -> module
  #   end
  # end
end
