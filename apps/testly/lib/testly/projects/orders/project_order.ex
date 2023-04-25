require EctoEnum

EctoEnum.defenum(Testly.Projects.ProjectOrderField, :project_order_field, [
  :domain
])

defmodule Testly.Projects.ProjectOrder do
  use Testly.Schema
  alias Testly.OrderDirection
  alias Testly.Projects.{ProjectQuery, ProjectOrderField}

  @primary_key false
  embedded_schema do
    field :direction, OrderDirection, default: :desc
    field :field, ProjectOrderField, default: :domain
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:direction, :field])
  end

  def query(query, %{direction: direction, field: field}) do
    ProjectQuery.order_by_field(query, direction, field)
  end
end
