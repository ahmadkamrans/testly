defmodule Testly.SessionEvents.AttributeMutation do
  use Testly.Schema

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :name, :string
    field :value, :string
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:id, :name, :value], empty_values: [])
    |> validate_required([:id, :name])
  end
end
