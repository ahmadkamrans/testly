defmodule TestlyMailerWeb.EmailTest do
  use ExUnit.Case, async: true
  alias TestlyMailer.Email

  @to "test@test.com"

  describe "#welcome_email/2" do
    test "works" do
      data = %{full_name: "John Smith", email: @to}

      email = Email.welcome_email(@to, data)

      assert %Bamboo.Email{to: @to} = email
      assert String.contains?(email.html_body, data.full_name)
    end
  end

  describe "#reset_password_email/2" do
    test "works" do
      data = %{full_name: "John Smith", token: "token"}

      email = Email.reset_password_email(@to, data)

      assert %Bamboo.Email{to: @to} = email
      assert String.contains?(email.html_body, data.full_name)
      assert String.contains?(email.html_body, data.token)
    end
  end
end
