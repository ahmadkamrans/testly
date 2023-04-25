defmodule Testly.Accounts.Changeset.PasswordValidator do
  @moduledoc false
  import Ecto.Changeset

  @spec validate(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate(ch, field_name) do
    validate_length(ch, field_name, min: 5)
  end
end
