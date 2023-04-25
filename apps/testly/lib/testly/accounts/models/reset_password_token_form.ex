defmodule Testly.Accounts.ResetPasswordTokenForm do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Testly.Accounts.User

  @type get_user_by_email :: (String.t() -> User.t() | nil)

  @type t :: %__MODULE__{
          email: String.t()
        }

  embedded_schema do
    field :email, :string, default: ""
  end

  @spec changeset(t(), map(), get_user_by_email()) :: Changeset.t()
  def changeset(form, params, get_user_by_email) do
    form
    |> cast(params, [:email])
    |> validate_required([:email])
    |> with_user(get_user_by_email)
  end

  defp with_user(%Changeset{valid?: true} = changeset, get_user_by_email) do
    email = get_field(changeset, :email)

    case get_user_by_email.(email) do
      %User{} -> changeset
      nil -> add_error(changeset, :email, "not found")
    end
  end

  defp with_user(%Changeset{valid?: false} = changeset, _get_user_by_email), do: changeset
end
