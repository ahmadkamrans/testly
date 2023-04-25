defmodule Testly.SplitTests.SplitTest do
  use Testly.Schema
  import Ecto.Query

  alias __MODULE__

  alias Testly.SplitTests.{
    Variation,
    FinishCondition,
    FinishConditionDb,
    SplitTestStatusEnum,
    PageCategory,
    PageType
  }

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
    has_one(:finish_condition_db, FinishConditionDb)
    field(:finish_condition, :map, virtual: true)
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

  def update_changeset(schema, params) do
    schema
    |> create_changeset(params)
    |> cast(params, [:traffic_percent, :traffic_device_types, :traffic_referrer_sources, :test_idea_id])
    |> validate_number(:traffic_percent, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
    # |> cast_assoc(:finish_condition)
    |> put_variation_indexes()
    |> cast_assoc(:variations, with: &Variation.changeset/2)
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

  # def settings_changeset(schema, params) do
  #   # TODO: Don't allow when traffic_device_types/traffic_referrer_sources both empty
  #   schema
  #   |> cast(params, [:traffic_percent, :traffic_device_types, :traffic_referrer_sources])
  #   |> validate_required([:traffic_percent])
  #   |> validate_number(:traffic_percent, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
  #   |> cast_assoc(:finish_condition, required: true)
  # end

  # def variations_changeset(schema, params) do
  #   schema
  #   |> cast(params, [])
  #   |> cast_assoc(:variations, required: true, with: &Variation.changeset/2)
  #   |> validate_length(:variations, min: 2)
  #   |> validate_variations_control
  # end

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

  def run_changeset(schema) do
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

  @spec preload_finish_condition(SplitTest.t()) :: SplitTest.t()
  def preload_finish_condition(%SplitTest{finish_condition_db: %FinishConditionDb{} = finish_condition_db} = split_test) do
    finish_condition = FinishCondition.to_finish_condition(finish_condition_db)
    Map.put(split_test, :finish_condition, finish_condition)
  end

  @spec preload_finish_condition([SplitTest.t()]) :: [SplitTest.t()]
  def preload_finish_condition(split_tests) when is_list(split_tests) do
    for split_test <- split_tests do
      preload_finish_condition(split_test)
    end
  end

  def preload_finish_condition(split_test), do: split_test

  def from_split_tests do
    from(s_t in SplitTest, as: :split_test)
  end

  def where_visits_to(session_recording_id) do
    from(s_t in SplitTest, as: :split_test)
    |> join(:left, [split_test: s_p], v in assoc(s_p, :variations), as: :variation)
    |> join(:left, [variation: v], v in assoc(v, :visits), as: :variation_visit)
    |> where([variation_visit: v_s], v_s.session_recording_id == ^session_recording_id)
    |> preload([variation: v, variation_visit: v_v], variations: {v, visits: v_v})
  end

  def where_project_id(query, project_id) do
    where(query, [split_test: s_t], s_t.project_id == ^project_id)
  end

  def where_status_active(query) do
    where(query, [split_test: s_t], s_t.status == "active")
  end

  def where_status_finished(query) do
    where(query, [split_test: s_t], s_t.status == "finished")
  end

  def where_status_in(query, statuses) do
    where(query, [split_test: s_t], s_t.status in ^statuses)
  end

  def paginate(query, page, per_page) do
    query
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
  end

  def distinct(query) do
    query
    |> distinct(true)
  end

  def order_by_created_at(query) do
    query
    |> order_by(desc: :created_at)
  end
end
