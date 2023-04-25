defmodule Testly.IdeaLab.Like do
  use Testly.Schema

  alias Testly.IdeaLab.{Idea}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          user_id: Testly.Schema.pk(),
          idea_id: Testly.Schema.pk(),
          created_at: String.t(),
          updated_at: String.t()
        }

  schema "test_idea_likes" do
    belongs_to :idea, Idea
    field :user_id, Ecto.UUID
    timestamps()
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:idea_id, :user_id])
    |> validate_required([:idea_id, :user_id])
  end
end
