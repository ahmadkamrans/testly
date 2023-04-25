defmodule Testly.Accounts.SendResetPasswordEmailWorker do

  @spec enqueue(String.t(), String.t(), String.t()) :: :ok
  def enqueue(to, full_name, token) do
    Exq.enqueue(Exq, "default", __MODULE__, [to, full_name, token])
    :ok
  end

  def perform(to, full_name, token)do
    TestlyMailer.Email.reset_password_email(
      to,
      %{full_name: full_name, token: token}
    )
    |> TestlyMailer.deliver_now()
  end
end
