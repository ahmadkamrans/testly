defmodule Testly.SessionRecordings.Device do
  use Testly.Schema

  alias Testly.SessionRecordings.SessionRecording
  alias Testly.SessionRecordings.DeviceTypeEnum

  alias UAInspector.Result.{Client, OS}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          session_recording_id: Testly.Schema.pk(),
          user_agent: String.t(),
          browser_name: String.t() | nil,
          browser_version: String.t() | nil,
          os_name: String.t() | nil,
          os_version: String.t() | nil,
          screen_height: pos_integer(),
          screen_width: pos_integer(),
          type: DeviceTypeEnum.t()
        }

  schema "session_recording_devices" do
    belongs_to :session_recording, SessionRecording

    field :user_agent, :string
    field :browser_name, :string
    field :browser_version, :string
    field :os_name, :string
    field :os_version, :string
    field :screen_height, :integer
    field :screen_width, :integer
    field :type, DeviceTypeEnum
  end

  def create_changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:user_agent, :screen_height, :screen_width])
    |> validate_required([:user_agent, :screen_height, :screen_width])
    |> put_type
  end

  defp put_type(changeset) do
    user_agent = get_field(changeset, :user_agent)
    result = UAInspector.parse(user_agent)

    changeset =
      case result.client do
        %Client{name: name, version: version} ->
          change(changeset, %{browser_name: value_to_string(name), browser_version: value_to_string(version)})

        :unknown ->
          changeset
      end

    changeset =
      case result.os do
        %OS{name: name, version: version} ->
          change(changeset, %{os_name: value_to_string(name), os_version: value_to_string(version)})

        :unknown ->
          changeset
      end

    type =
      case result do
        %{device: %{type: "tablet"}} -> :tablet
        %{device: %{type: "smartphone"}} -> :mobile
        %{device: %{type: "phablet"}} -> :mobile
        _ -> :desktop
      end

    put_change(changeset, :type, type)
  end

  def value_to_string(:unknown), do: ""
  def value_to_string(data), do: data
end
