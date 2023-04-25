defmodule Testly.Accounts.UserQuery do
  import Ecto.Query

  alias Testly.Accounts.User

  def from_user do
    from(u in User, as: :user)
  end

  def order_by_field(query, direction, field) do
    order_by(query, [], [{^direction, ^field}])
  end

  def where_email_cont(query, value) do
    where(query, [user: u], ilike(u.email, ^"%#{value}%"))
  end

  def where_full_name_cont(query, value) do
    where(query, [user: u], ilike(u.full_name, ^"%#{value}%"))
  end

  def where_company_name_cont(query, value) do
    where(query, [user: u], ilike(u.company_name, ^"%#{value}%"))
  end
end
