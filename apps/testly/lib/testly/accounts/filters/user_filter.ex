defmodule Testly.Accounts.UserFilter do
  use Testly.Schema
  alias Testly.Accounts.{UserQuery}

  @type t() :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :full_name_cont, :string
    field :email_cont, :string
    field :company_name_cont, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:full_name_cont, :email_cont, :company_name_cont])
  end

  def query(query, filter) do
    Testly.FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:full_name_cont, query, value) do
    UserQuery.where_full_name_cont(query, value)
  end

  defp query_filter(:email_cont, query, value) do
    UserQuery.where_email_cont(query, value)
  end

  defp query_filter(:company_name_cont, query, value) do
    UserQuery.where_company_name_cont(query, value)
  end
end
