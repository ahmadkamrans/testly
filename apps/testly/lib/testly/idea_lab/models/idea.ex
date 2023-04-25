defmodule Testly.IdeaLab.Idea do
  use Testly.Schema
  use Arc.Ecto.Schema

  alias Testly.IdeaLab.{Category, Cover, Like}
  alias Testly.ArcFixer

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          category_id: Testly.Schema.pk(),
          title: String.t(),
          description: String.t(),
          impact_rate: integer(),
          created_at: String.t(),
          updated_at: String.t()
        }

  schema "test_ideas" do
    belongs_to :category, Category
    has_many :likes, Like

    field :title, :string
    field :description, :string
    field :impact_rate, :integer
    field :cover, Cover.Type
    field :cover_url, :string, virtual: true
    timestamps()
  end

  def changeset(schema, params) do
    schema
    |> generate_uuid_on_empty()
    |> cast(params, [:category_id, :title, :description, :impact_rate])
    |> cast_attachments(params, [:cover])
    |> validate_required([:category_id, :title, :description, :impact_rate, :cover])
  end

  defp generate_uuid_on_empty(schema) do
    if schema.id do
      schema
    else
      %{schema | id: Ecto.UUID.generate()}
    end
  end

  def populate_cover_url(idea) do
    %{idea | cover_url: ArcFixer.fix_upload_url(Cover.url({idea.cover, idea}))}
  end
end
