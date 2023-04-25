defmodule Testly.SplitTests.SplitTest do
  use Testly.Schema
  import Ecto.Query

  alias Testly.SplitTests.{
    Variation,
    FinishCondition,
    SplitTestStatusEnum,
    PageCategory,
    PageType,
    Goal
  }

  alias Testly.Goals.{Goal}

  alias Testly.SessionRecordings.{DeviceTypeEnum, ReferrerSourceEnum}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          project_id: Testly.Schema.pk(),
          test_idea_id: Testly.Schema.pk(),
          finish_condition: FinishCondition.t(),
          name: String.t(),
          description: String.t()
        }

  schema "split_tests" do
    belongs_to(:page_category, PageCategory)
    belongs_to(:page_type, PageType)
    has_many(:variations, Variation, on_replace: :delete)
    has_one(:finish_condition, FinishCondition)
    many_to_many :goals, Goal, join_through: "split_tests_goals"
    field(:test_idea_id, Ecto.UUID)
    field(:project_id, Ecto.UUID)
    field(:name, :string)
    field(:description, :string, default: "")
    field(:traffic_percent, :integer, default: 100)
    field(:traffic_device_types, {:array, DeviceTypeEnum}, default: [:desktop, :mobile, :tablet])
    field(:finished_at, :utc_datetime)

    field(:traffic_referrer_sources, {:array, ReferrerSourceEnum},
      default: [:social, :search, :paid, :email, :direct, :unknown]
    )

    field(:status, SplitTestStatusEnum, default: :draft)
    timestamps()
  end

  def create_changeset(schema, params) do
    schema
    |> cast(params, [:name, :description, :page_category_id, :page_type_id, :test_idea_id])
    |> validate_required([:name, :page_category_id, :page_type_id])
    |> validate_length(:name, max: 255)
    |> validate_length(:description, max: 2000)
  end

  def update_changeset(schema, params, goals) do
    schema
    |> create_changeset(params)
    |> cast(params, [:traffic_percent, :traffic_device_types, :traffic_referrer_sources, :test_idea_id])
    |> validate_number(:traffic_percent, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
    |> put_variation_indexes()
    |> cast_assoc(:variations, with: &Variation.changeset/2)
    |> cast_assoc(:finish_condition, with: &FinishCondition.changeset/2)
    |> put_assoc(:goals, goals)
    |> validate_length(:variations, min: 2)
    |> validate_variations_control()
  end

  defp put_variation_indexes(%Changeset{changes: %{variations: _variations}} = changeset) do
    variations =
      changeset
      |> get_change(:variations)
      |> Enum.with_index()
      |> Enum.map(fn {ch, i} -> put_change(ch, :index, i) end)

    put_change(changeset, :variations, variations)
  end

  defp put_variation_indexes(changeset), do: changeset

  defp validate_variations_control(%Changeset{changes: %{variations: _variations}} = changeset) do
    changeset
    |> get_field(:variations)
    |> Enum.count(& &1.control)
    |> case do
      1 -> changeset
      _ -> add_error(changeset, :variations, "one control variation must exists")
    end
  end

  defp validate_variations_control(changeset), do: changeset

  def activate_changeset(schema) do
    # TODO: validate all required fields for activation
    schema
    |> change(%{status: :active})
  end

  def finish_changeset(schema) do
    schema
    |> change(%{status: :finished, finished_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  def pause_changeset(schema) do
    schema
    |> change(%{status: :paused})
  end

  def determine_variation_for_visit(split_test) do
    Enum.min_by(split_test.variations, &Enum.count(&1.visits))
  end
end
