defmodule Testly.SessionEvents.DOMMutatedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :dom_mutated

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :origin, :string
      field :removed, {:array, :integer}

      embeds_many :added_or_moved, Testly.SessionEvents.AddedOrMovedMutation
      embeds_many :attributes, Testly.SessionEvents.AttributeMutation
      embeds_many :character_data, Testly.SessionEvents.CharacterMutation
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:origin, :removed])
    |> validate_required([:origin])
    |> cast_embed(:attributes)
    |> cast_embed(:added_or_moved)
    |> cast_embed(:character_data)
  end
end
