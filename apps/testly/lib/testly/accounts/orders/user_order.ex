require EctoEnum

EctoEnum.defenum(Testly.Accounts.UserOrderField, :accounts_user_order_field, [
  :full_name,
  :email,
  :created_at
])

defmodule Testly.Accounts.UserOrder do
  use Testly.Schema
  alias Testly.OrderDirection
  alias Testly.Accounts.{UserQuery, UserOrderField}

  @primary_key false
  embedded_schema do
    field :direction, OrderDirection, default: :desc
    field :field, UserOrderField, default: :created_at
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:direction, :field])
  end

  def query(query, %{direction: direction, field: field}) do
    UserQuery.order_by_field(query, direction, field)
  end
end
