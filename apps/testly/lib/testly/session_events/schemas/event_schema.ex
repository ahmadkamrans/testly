defmodule Testly.SessionEvents.EventSchema do
  use Testly.Schema

  alias Testly.SessionEvents.EventTypeEnum

  @type t :: %__MODULE__{
          id: Ecto.Schema.pk(),
          session_recording_id: Ecto.Schema.pk(),
          page_id: Ecto.Schema.pk(),
          is_processed: boolean(),
          happened_at: DateTime.t(),
          type: EventTypeEnum.t(),
          data: map()
        }

  schema "session_recording_events" do
    field :session_recording_id, Ecto.UUID
    field :page_id, Ecto.UUID
    field :is_processed, :boolean, default: false
    field :happened_at, :utc_datetime_usec
    field :type, EventTypeEnum
    field :data, :map
  end
end
