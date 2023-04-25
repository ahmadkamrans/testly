defmodule Testly.IdeaLab.Category do
  use Testly.Schema
  use Arc.Ecto.Schema

  alias Testly.IdeaLab.CategoryIcon

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          name: String.t(),
          color: integer(),
          created_at: String.t(),
          updated_at: String.t()
        }

  schema "test_idea_categories" do
    field :name, :string
    field :color, :string
    field :icon, CategoryIcon.Type
    timestamps()
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:name, :color])
    |> cast_attachments(params, [:icon])
    |> validate_required([:name, :color, :icon])
  end
end
