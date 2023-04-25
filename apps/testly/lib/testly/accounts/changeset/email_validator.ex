defmodule Testly.Accounts.Changeset.EmailValidator do
  @moduledoc false
  import Ecto.Changeset

  alias Ecto.Changeset

  @type was_email_taken :: (String.t() -> boolean())

  @spec validate(Changeset.t(), was_email_taken()) :: Changeset.t()
  def validate(%Changeset{} = ch, was_email_taken?) do
    ch
    |> validate_format(:email, ~r/@/)
    |> not_taken(was_email_taken?)
  end

  @spec not_taken(Changeset.t(), (String.t() -> boolean())) :: Changeset.t()
  defp not_taken(ch, was_email_taken?) do
    email = get_field(ch, :email)
    was_taken = (email && was_email_taken?.(email)) || false

    if was_taken do
      add_error(ch, :email, "has already been taken")
    else
      ch
    end
  end
end
