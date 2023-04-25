defmodule TestlyHome.ContactsHelper do
  @contacts Application.get_env(:testly_home, :contacts)

  @email Keyword.fetch!(@contacts, :support_email)

  def contact_support_email, do: @email
end
