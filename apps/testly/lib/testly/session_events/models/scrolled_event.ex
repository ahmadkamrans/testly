defmodule Testly.SessionEvents.ScrolledEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :scrolled

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :top, :float
      field :left, :float
      field :id, :integer
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:top, :left, :id])
    |> validate_required([:top, :left, :id])
  end
end
