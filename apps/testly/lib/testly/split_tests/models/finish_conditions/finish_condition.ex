defmodule Testly.SplitTests.FinishCondition do
  @moduledoc """
    Base module for finish conditions.
    Use FinishConditionDB for persistence
  """
  alias Ecto.Changeset
  alias Testly.SplitTests.SplitTest
  alias Testly.SplitTests.FinishConditionTypeEnum
  alias Testly.SplitTests.{VisitsFinishCondition, DaysPassedFinishCondition, GoalConversionsFinishCondition}

  @type t ::
          VisitsFinishCondition.t()
          | DaysPassedFinishCondition.t()
          | GoalConversionsFinishCondition.t()

  @callback changeset(term(), map()) :: Changeset.t()
  @callback cast_fields(Changeset.t(), map()) :: Changeset.t()

  @type_map %{
    "visits" => VisitsFinishCondition,
    "days_passed" => DaysPassedFinishCondition,
    "goal_conversions" => GoalConversionsFinishCondition
  }

  defp type_to_module(type) do
    case @type_map[to_string(type)] do
      nil -> raise "Unknown type #{inspect(type)}"
      module -> module
    end
  end

  @spec to_finish_condition(FinishConditionDb.t()) :: FinishCondition.t()
  def to_finish_condition(finish_condition_db) do
    type_to_module(finish_condition_db.type).to_finish_condition(finish_condition_db)
  end

  @spec changeset(String.t(), map()) :: Changeset.t()
  def changeset(%SplitTest{id: split_test_id} = split_test, params) do
    module = type_to_module(params[:type] || params["type"])

    id =
      if split_test.finish_condition do
        split_test.finish_condition.id
      else
        nil
      end

    module
    |> struct(id: id, split_test_id: split_test_id)
    |> module.changeset(params)
  end

  # @spec changeset(FinishCondition.t(), map()) :: Changeset.t()
  # def changeset(finish_condition, params) do
  #   finish_condition.__struct__.changeset(finish_condition, params)
  # end

  defmacro __using__(_) do
    quote do
      use Testly.Schema
      @behaviour Testly.SplitTests.FinishCondition
      import Testly.SplitTests.FinishCondition, only: [finish_condition_schema: 1]
    end
  end

  defmacro finish_condition_schema(do: block) do
    quote do
      alias Testly.SplitTests.{FinishConditionTypeEnum, FinishConditionDb}

      @primary_key false
      embedded_schema do
        field :id, Ecto.UUID
        field :split_test_id, Ecto.UUID
        unquote(block)
      end

      def to_finish_condition(%FinishConditionDb{} = finish_condition_db) do
        params = Map.from_struct(finish_condition_db)

        struct(__MODULE__)
        |> cast_common_fields(params)
        |> cast_fields(params)
        |> Changeset.apply_changes()
      end

      defp cast_common_fields(schema, params) do
        schema
        |> cast(params, [:id, :split_test_id])
      end
    end
  end
end
