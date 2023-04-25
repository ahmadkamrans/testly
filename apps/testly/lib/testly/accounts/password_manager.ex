defmodule Testly.Accounts.PasswordManager do
  alias Comeonin.Bcrypt

  @spec encrypt(String.t()) :: String.t()
  def encrypt(password), do: Bcrypt.hashpwsalt(password)

  @spec check?(String.t(), String.t()) :: boolean()
  def check?(password, encrypted_password), do: Bcrypt.checkpw(password, encrypted_password)
end
