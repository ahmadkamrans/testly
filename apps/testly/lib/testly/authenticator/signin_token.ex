defmodule Testly.Authenticator.SignInToken do
  use Joken.Config

  def token_config, do: default_claims(default_exp: 10)

  def encode!(user_id) do
    generate_and_sign!(%{"user_id" => user_id})
  end

  def decode!(token) do
    verify_and_validate!(token)
    |> Map.fetch!("user_id")
  end
end
