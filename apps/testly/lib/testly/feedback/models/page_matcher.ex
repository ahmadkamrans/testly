defmodule Testly.Feedback.PageMatcher do
  use Testly.Schema

  alias Testly.PageMatcherType

  embedded_schema do
    field :match_type, PageMatcherType
    field :url, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:url, :match_type])
    |> validate_required([:url, :match_type])
  end
end
