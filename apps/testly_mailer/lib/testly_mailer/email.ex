defmodule TestlyMailer.Email do
  @support_from Keyword.fetch!(Application.fetch_env!(:testly_mailer, __MODULE__), :support_from)

  use Bamboo.Phoenix, view: TestlyMailer.EmailView

  @spec welcome_email(Bamboo.Email.address_list(), %{full_name: String.t()}) :: Bamboo.Email.t()
  def welcome_email(to, %{full_name: full_name, email: email}) do
    new_email()
    |> from(@support_from)
    |> to(to)
    |> subject("Welcome to Testly! [Account information inside]")
    |> assign(:email, email)
    |> assign(:full_name, full_name)
    |> render("welcome.html")
  end

  @spec reset_password_email(Bamboo.Email.address_list(), %{full_name: String.t(), token: String.t()}) ::
          Bamboo.Email.t()
  def reset_password_email(to, %{full_name: full_name, token: token}) do
    new_email()
    |> from(@support_from)
    |> to(to)
    |> subject("Password Reset Instructions")
    |> assign(:full_name, full_name)
    |> assign(:token, token)
    |> render("reset_password.html")
  end
end
