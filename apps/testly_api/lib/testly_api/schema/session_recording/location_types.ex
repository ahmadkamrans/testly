defmodule TestlyAPI.Schema.SessionRecording.LocationType do
  use Absinthe.Schema.Notation

  object :session_recording_location do
    field :id, non_null(:uuid4)

    field :ip, non_null(:string)
    field :country, :string
    field :country_iso_code, :string
    field :city, :string
  end
end
