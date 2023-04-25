defmodule Testly.SessionRecordings.Location do
  use Testly.Schema

  alias Testly.SessionRecordings.SessionRecording

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          session_recording_id: Testly.Schema.pk(),
          ip: String.t(),
          country: String.t(),
          country_iso_code: String.t(),
          city: String.t(),
          latitude: float(),
          longitude: float()
        }

  schema "session_recording_locations" do
    belongs_to :session_recording, SessionRecording

    field :ip, :string
    field :country, :string
    field :country_iso_code, :string
    field :city, :string
    field :latitude, :float
    field :longitude, :float
  end

  def create_changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:ip])
    |> validate_required([:ip])
    |> put_geo_data()
  end

  defp put_geo_data(%{valid?: false} = changeset), do: changeset

  defp put_geo_data(%{valid?: true} = changeset) do
    ip = get_field(changeset, :ip)

    case Geolix.lookup(ip) do
      %{
        cities_db: %{
          country: country,
          city: city,
          location: location
        }
      } ->
        changeset =
          case country do
            %{name: name, iso_code: iso_code} ->
              changeset
              |> put_change(:country, name)
              |> put_change(:country_iso_code, iso_code)

            _ -> changeset
          end

        changeset =
          case city do
            %{name: name} -> put_change(changeset, :city, name)
            _ -> changeset
          end

        case location do
          %{latitude: latitude, longitude: longitude} ->
            changeset
            |> put_change(:latitude, latitude)
            |> put_change(:longitude, longitude)

          _ ->
            changeset
        end

      _ ->
        changeset
    end
  end
end
