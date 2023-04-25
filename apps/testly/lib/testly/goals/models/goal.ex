defmodule Testly.Goals.Goal do
  @moduledoc """
    Base module for type goals
  """

  alias Ecto.Changeset
  alias Testly.Projects.Project
  alias Testly.SplitTests.SplitTest

  @type assoc :: Project.t() | SplitTest.t()
  @type goal :: PathGoal.t()
  @type t :: PathGoal.t()

  alias Testly.Goals.PathGoal

  @modules %{
    "path" => Testly.Goals.PathGoal
  }

  @spec changeset(String.t(), map()) :: Changeset.t()
  def changeset(assoc_id, params) do
    module = type_to_module(params["type"] || params[:type])

    module
    |> struct(assoc_id: assoc_id)
    |> module.changeset(params)
  end

  @spec update_changeset(Goal.t(), map()) :: Changeset.t()
  def update_changeset(schema, params) do
    module = type_to_module(params["type"] || params[:type])

    module.changeset(schema, params)
    |> Map.put(:action, :update)
  end

  @spec delete_changeset(Goal.t()) :: Changeset.t()
  def delete_changeset(schema) do
    schema
    |> Changeset.change()
    |> Map.put(:action, :delete)
  end

  @spec changesets(String.t(), [Goal.t()], [map()]) :: {:ok, [Changeset.t()]} | {:error, [Changeset.t()]}
  def changesets(assoc_id, goals, goals_params) do
    goals_params =
      goals_params
      |> Enum.with_index()
      |> Enum.map(fn {params, i} ->
        put_in(params[:index], i)
      end)

    update_changesets =
      for goal <- goals do
        case Enum.find(goals_params, &(&1[:id] == goal.id)) do
          nil -> delete_changeset(goal)
          goal_params -> update_changeset(goal, goal_params)
        end
      end

    create_changesets =
      for goal_params <- goals_params, goal_params[:id] == nil do
        changeset(assoc_id, goal_params)
        |> Map.put(:action, :insert)
      end

    changesets = update_changesets ++ create_changesets

    invalid_changesets = Enum.filter(changesets, &(&1.valid? == false))

    if Enum.empty?(invalid_changesets) do
      {:ok, changesets}
    else
      {:error, invalid_changesets}
    end
  end

  def to_goal(goal) do
    type_to_module(goal.type).to_goal(goal)
  end

  def check_conversion(goal, session_recording) do
    PathGoal.check_conversion(goal, session_recording)
  end

  defp type_to_module(type) do
    case @modules[to_string(type)] do
      nil -> raise "Unknown type #{inspect(type)}"
      module -> module
    end
  end

  defmacro __using__(_) do
    quote do
      use Testly.Schema
      alias Testly.Goals.GoalTypeEnum
      import Testly.Goals.Goal, only: [goal_model: 1]
    end
  end

  defmacro goal_model(do: block) do
    quote do
      alias Testly.Goals.{ProjectGoal, SplitTestGoal, Conversion}

      @primary_key false
      embedded_schema do
        field :id, Ecto.UUID
        field :assoc_id, Ecto.UUID
        # field :assoc_type, SplitTest | Project
        embeds_many :conversions, Conversion
        field :name, :string
        field :value, :decimal, default: Decimal.from_float(0.0)
        field :index, :integer
        timestamps()
        unquote(block)
      end

      @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
      def changeset(schema, params) do
        schema
        |> cast(params, [:name, :value, :index])
        |> validate_required([:name])
        |> goal_changeset(params)
      end

      def to_goal(%ProjectGoal{project_id: project_id} = goal) do
        params = Map.from_struct(goal)

        project_id
        |> cast_common_fields(params)
        |> cast_fields(params)
        |> Ecto.Changeset.apply_changes()
      end

      def to_goal(%SplitTestGoal{split_test_id: split_test_id} = goal) do
        params = Map.from_struct(goal)

        split_test_id
        |> cast_common_fields(params)
        |> cast_fields(params)
        |> Ecto.Changeset.apply_changes()
      end

      defp cast_common_fields(assoc_id, params) do
        is_loaded = Ecto.assoc_loaded?(params[:conversions])

        struct(__MODULE__, assoc_id: assoc_id)
        |> cast(params, [:id, :name, :value, :created_at, :updated_at])
        |> case do
          d when is_loaded == true -> cast_embed(d, :conversions, with: &Conversion.cast_fields/2)
          c -> c
        end
      end
    end
  end
end
