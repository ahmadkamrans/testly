defmodule Testly.Accounts.Worker do
  @behaviour Honeydew.Worker
  @queue :accounts_queue

  alias Testly.Accounts.{
    User
  }

  def enqueue_send_reset_password_email(%User{email: to, full_name: full_name, reset_password_token: token}) do
    Honeydew.async({:send_reset_password_email, [to, full_name, token]}, @queue)
  end

  def enqueue_send_welcome_email(%User{email: to, full_name: full_name}) do
    Honeydew.async({:send_welcome_email, [to, full_name]}, @queue)
  end

  #####

  def send_reset_password_email(to, full_name, token) do
    TestlyMailer.Email.reset_password_email(
      to,
      %{full_name: full_name, token: token}
    )
    |> TestlyMailer.deliver_now()
  end

  def send_welcome_email(to, full_name) do
    TestlyMailer.Email.welcome_email(
      to,
      %{full_name: full_name, email: to}
    )
    |> TestlyMailer.deliver_now()
  end
end
