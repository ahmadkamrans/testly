defmodule TestlyMailer.EmailView do
  use Phoenix.View,
    root: "lib/testly_mailer/templates",
    namespace: TestlyMailer

  use Phoenix.HTML

  @urls Application.get_env(:testly_mailer, :external_urls)
  @support_url Keyword.fetch!(@urls, :support_url)
  @reset_password_form_url Keyword.fetch!(@urls, :reset_password_form_url)
  @login_url Keyword.fetch!(@urls, :login_url)

  def support_url, do: @support_url

  def login_url, do: @login_url

  def reset_password_form_url(token) do
    "#{@reset_password_form_url}?#{URI.encode_query(%{token: token})}"
  end
end
