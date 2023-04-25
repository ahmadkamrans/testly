defmodule TestlyMailer.EmailView do
  use Phoenix.View,
    root: "lib/testly_mailer/templates",
    namespace: TestlyMailer

  use Phoenix.HTML

  def support_url, do: fetch!(:support_url)

  def login_url, do: fetch!(:login_url)

  def reset_password_form_url(token) do
    "#{fetch!(:reset_password_form_url)}?#{URI.encode_query(%{token: token})}"
  end

  def fetch!(key) do
    Application.get_env(:testly_mailer, :external_urls)
    |> Keyword.fetch!(key)
  end
end
