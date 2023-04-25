defmodule Testly.Accounts.ResetPasswordForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Testly.Accounts.Changeset.PasswordValidator

  @type t :: %__MODULE__{
          password: String.t()
        }

  embedded_schema do
    field :password, :string, default: ""
  end

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(form, params) do
    form
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> PasswordValidator.validate(:password)

    # |> validate_token_time(get_user_by_token, @token_lifetime_hours)
  end

  # @spec validate_token_time(Changeset.t(), get_user_by_token(), pos_integer()) ::
  #         {Changeset.t(), User.t() | nil}
  # defp validate_token_time(%Changeset{valid?: true} = ch, get_user_by_token, token_lifetime_hours) do
  #   token = get_field(ch, :token)
  #   user = get_user_by_token.(token)

  #   time_diff_hours = user && Timex.diff(Timex.now(), user.reset_password_generated_at, :hours)

  #   case {user, time_diff_hours > token_lifetime_hours} do
  #      {nil, _} -> add_error(ch, :token, "not found")
  #      {_, true} -> add_error(ch, :token, "expired")
  #      _ -> ch
  #    end
  # end

  # defp validate_token_time(%Changeset{valid?: false} = ch, _, _), do: {ch, nil}
end
