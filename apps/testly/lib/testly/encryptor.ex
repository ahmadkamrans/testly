# Taken from https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/aes.ex
defmodule Testly.Encryptor do
  @moduledoc """
  Encrypt values with AES in Galois/Counter Mode (GCM)
  https://en.wikipedia.org/wiki/Galois/Counter_Mode
  using a random Initialisation Vector for each encryption,
  this makes "bruteforce" decryption much more difficult.
  """
  # Use AES 256 Bit Keys for Encryption.
  @aad "AES256GCM"

  @spec encrypt(String.t(), bitstring()) :: bitstring()
  def encrypt(plaintext, key) do
    # create random Initialisation Vector
    iv = :crypto.strong_rand_bytes(16)
    {ciphertext, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    # "return" iv with the cipher tag & ciphertext
    iv <> tag <> ciphertext
  end

  @spec decrypt(String.t(), bitstring()) :: String.t()
  def decrypt(ciphertext, key) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, tag})
  end
end
