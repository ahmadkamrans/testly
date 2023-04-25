defmodule Testly.SessionEvents.AddedOrMovedMutation do
  use Testly.Schema

  alias Testly.SessionEvents.DOMNode

  @primary_key false
  embedded_schema do
    field :parent, :integer
    field :previous_sibling, :integer

    embeds_one :node, DOMNode
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:parent, :previous_sibling])
    |> cast_embed(:node)
    |> validate_required([:parent, :node])
  end
end
