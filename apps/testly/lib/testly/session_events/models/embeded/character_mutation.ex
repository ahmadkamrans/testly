defmodule Testly.SessionEvents.CharacterMutation do
  use Testly.Schema

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :data, :string
    field :parent_tag_name, :string
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:id, :data, :parent_tag_name])
    |> validate_required([:id, :data, :parent_tag_name])
  end
end
