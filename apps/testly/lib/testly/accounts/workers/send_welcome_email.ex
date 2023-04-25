defmodule Testly.Accounts.SendWelcomeEmailWorker do

  @spec enqueue(String.t(), String.t(), String.t()) :: :ok
  def enqueue(to, full_name, email) do
    Exq.enqueue(Exq, "default", __MODULE__, [to, full_name, email])
    :ok
  end

  def perform(to, full_name, email) do
    TestlyMailer.Email.welcome_email(
      to,
      %{full_name: full_name, email: email}
    )
    |> TestlyMailer.deliver_now()
  end
end
