defmodule Testly.SessionEvents.MouseMovedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :mouse_moved

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :x, :integer
      field :y, :integer
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:x, :y])
    |> validate_required([:x, :y])
  end
end
