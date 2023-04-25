use Mix.Config

# TODO: Use ENV
config :testly_mailer, :external_urls,
  reset_password_form_url: "https://stage.testly.com/user/password/edit",
  login_url: "https://stage.testly.com/sessions/new"

config :testly_mailer, TestlyMailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.mailgun.org",
  hostname: "testly.com",
  port: 587,
  # or {:system, "SMTP_USERNAME"}
  username: "postmaster@mail.testly.com",
  # or {:system, "SMTP_PASSWORD"}
  password: "e146c0b03776ea16f3ed3d105926a338",
  # can be `:always` or `:never`
  tls: :if_available,
  # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  # can be `true`
  ssl: false,
  retries: 1,
  # can be `true`
  no_mx_lookups: false,
  # can be `always`. If your smtp relay requires authentication set it to `always`.
  auth: :always
