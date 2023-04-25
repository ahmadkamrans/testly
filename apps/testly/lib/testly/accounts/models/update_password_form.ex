defmodule Testly.Accounts.UpdatePasswordForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Testly.Accounts.Changeset.PasswordValidator
  alias Testly.Accounts.User

  @type t :: %__MODULE__{
          current_password: String.t(),
          new_password: String.t()
        }

  embedded_schema do
    field :current_password, :string, default: ""
    field :new_password, :string, default: ""
  end

  @spec changeset(t(), map(), User.t(), (String.t(), String.t() -> boolean())) :: Changeset.t()
  def changeset(form, params, user, check_password_equality) do
    form
    |> cast(params, [:current_password, :new_password])
    |> validate_required([:current_password, :new_password])
    |> validate_password_equality(user, check_password_equality)
    |> PasswordValidator.validate(:new_password)
  end

  @spec validate_password_equality(Changeset.t(), User.t(), (String.t(), String.t() -> boolean())) :: Changeset.t()
  defp validate_password_equality(%Changeset{valid?: true} = ch, user, check_password_equality) do
    if check_password_equality.(get_field(ch, :current_password), user.encrypted_password) do
      ch
    else
      add_error(ch, :current_password, "is wrong")
    end
  end

  defp validate_password_equality(ch, _user, _encrypt_password), do: ch
end
