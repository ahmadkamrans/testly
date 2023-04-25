defmodule Testly.SessionEvents.MouseClickedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :mouse_clicked

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :x, :integer
      field :y, :integer
      field :percent_x, :float
      field :percent_y, :float
      field :selector, :string
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:x, :y, :percent_x, :percent_y, :selector])
    |> validate_required([:x, :y, :percent_x, :percent_y, :selector])
  end
end
