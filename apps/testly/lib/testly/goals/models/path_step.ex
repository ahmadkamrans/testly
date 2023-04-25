defmodule Testly.Goals.PathStep do
  use Testly.Schema

  alias __MODULE__

  alias Testly.Goals.MatchTypeEnum

  @type t :: %PathStep{
          index: integer,
          url: String.t(),
          match_type: MatchTypeEnum.t()
        }

  @primary_key false
  embedded_schema do
    field :index, :integer
    field :url, :string
    field :match_type, MatchTypeEnum
  end

  @spec changeset(%PathStep{}, map) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:index, :url, :match_type])
    |> validate_required([:index, :url, :match_type])
  end

  @spec match?(%PathStep{}, String.t()) :: boolean
  def match?(%PathStep{match_type: :matches_exactly} = path_step, url) do
    url == path_step.url
  end

  def match?(%PathStep{match_type: :contains} = path_step, url) do
    String.contains?(url, path_step.url)
  end

  def match?(%PathStep{match_type: :begins_with} = path_step, url) do
    String.starts_with?(url, path_step.url)
  end

  def match?(%PathStep{match_type: :ends_with} = path_step, url) do
    String.ends_with?(url, path_step.url)
  end
end
