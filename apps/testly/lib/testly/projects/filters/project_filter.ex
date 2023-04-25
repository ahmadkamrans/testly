defmodule Testly.Projects.ProjectFilter do
  use Testly.Schema
  alias Testly.Projects.{ProjectQuery}

  @type t() :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :domain_cont, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:domain_cont])
  end

  def query(query, filter) do
    Testly.FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:domain_cont, query, value) do
    ProjectQuery.where_domain_cont(query, value)
  end
end
