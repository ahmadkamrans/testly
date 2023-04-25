defmodule Testly.SessionEvents.ElementAttribute do
  use Testly.Schema

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:name, :value], empty_values: [])
    |> validate_required([:name])
  end
end
