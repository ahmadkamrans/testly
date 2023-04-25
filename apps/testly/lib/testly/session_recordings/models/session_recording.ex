defmodule Testly.SessionRecordings.SessionRecording do
  use Testly.Schema

  alias Testly.SessionRecordings.{
    Device,
    Location,
    ReferrerSourceEnum,
    Page,
    ProjectGoal
  }

  alias Testly.SessionRecordings.SplitTest.VariationVisit

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          project_id: Testly.Schema.pk(),
          location: Location.t(),
          device: Device.t(),
          duration: integer(),
          clicks_count: integer(),
          referrer: String.t() | nil,
          referrer_source: ReferrerSourceEnum.t(),
          is_ready: boolean(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "session_recordings" do
    many_to_many :converted_project_goals, ProjectGoal,
      join_through: "project_goal_conversions",
      join_keys: [session_recording_id: :id, project_goal_id: :id]

    has_many :split_test_variation_visits, VariationVisit
    has_many :split_test_variations, through: [:split_test_variation_visits, :variation]
    has_many :split_test_goal_conversions, through: [:split_test_variation_visits, :goal_conversions]
    has_many :split_test_goals, through: [:split_test_goal_conversions, :goal]

    has_one :split_test_variation, through: [:split_test_variation_visits, :variation]

    has_one :location, Location
    has_one :device, Device
    has_many :pages, Page

    field :project_id, Ecto.UUID
    field :duration, :integer
    field :clicks_count, :integer
    field :referrer, :string
    field :referrer_source, ReferrerSourceEnum
    field :is_ready, :boolean, default: false

    timestamps()
  end

  def create_changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:referrer])
    |> put_refferer_source
    |> cast_assoc(:location, required: true, with: &Location.create_changeset/2)
    |> cast_assoc(:device, required: true, with: &Device.create_changeset/2)
  end

  defp put_refferer_source(changeset) do
    referrer = get_field(changeset, :referrer) || ""

    referrer_source =
      case RefInspector.parse(referrer) do
        %{medium: :search} ->
          :search

        %{medium: :email} ->
          :email

        %{medium: :paid} ->
          :paid

        %{medium: :social} ->
          :social

        _ ->
          if(String.trim(referrer) == "", do: :direct, else: :unknown)
      end

    put_change(changeset, :referrer_source, referrer_source)
  end
end
