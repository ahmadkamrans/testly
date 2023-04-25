defmodule Testly.Accounts.SignInForm do
  use Testly.Schema
  alias Ecto.Changeset
  alias Testly.Accounts.User

  @type get_user_by_email :: (String.t() -> User.t() | nil)
  @type password_match? :: (String.t(), String.t() -> boolean())

  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t(),
          remember_me: boolean()
        }

  embedded_schema do
    field :email, :string, default: ""
    field :password, :string, default: ""
    field :remember_me, :boolean, default: false
  end

  @spec changeset(t(), map(), get_user_by_email(), password_match?()) :: Changeset.t()
  def changeset(form, params, get_user_by_email, password_match?) do
    form
    |> cast(params, [:email, :password, :remember_me])
    |> validate_required([:email, :password])
    |> validate_email_and_password(get_user_by_email, password_match?)
  end

  defp validate_email_and_password(%Changeset{valid?: true} = changeset, get_user_by_email, password_match?) do
    email = get_field(changeset, :email)
    password = get_field(changeset, :password)

    case get_user_by_email.(email) do
      %User{} = user ->
        if password_match?.(password, user.encrypted_password) do
          changeset
        else
          add_error(changeset, :password, "Wrong password")
        end

      nil ->
        add_error(changeset, :email, "User with this email does not exist")
    end
  end

  defp validate_email_and_password(%Changeset{valid?: false} = changeset, _, _), do: changeset
end
