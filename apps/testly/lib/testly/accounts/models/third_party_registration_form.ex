defmodule Testly.Accounts.ThirdPartyRegistrationForm do
  use Testly.Schema
  alias Ecto.Changeset
  alias Testly.Accounts.Changeset.EmailValidator

  @type t :: %__MODULE__{
          full_name: String.t(),
          email: String.t(),
          facebook_identifier: String.t(),
          tos_accepted: boolean()
        }

  embedded_schema do
    field :full_name, :string, default: ""
    field :email, :string, default: ""

    # one of
    field :facebook_identifier, :string, default: ""
    # field :twitter_identifier, :string

    field :tos_accepted, :boolean, default: false
  end

  @spec changeset(t(), map(), EmailValidator.was_email_taken()) :: Changeset.t()
  def changeset(form, params, was_email_taken?) do
    form
    |> cast(params, [:full_name, :email, :facebook_identifier, :tos_accepted])
    |> validate_required([:full_name, :email, :tos_accepted])
    # if we will support another one provider
    |> validate_required_inclusion([:facebook_identifier])
    |> validate_acceptance(:tos_accepted)
    |> EmailValidator.validate(was_email_taken?)
  end

  @spec validate_required_inclusion(Changeset.t(), [atom()]) :: Changeset.t()
  defp validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, fn field -> String.trim(get_field(changeset, field)) != "" end),
      do: changeset,
      else:
        add_error(
          changeset,
          hd(fields),
          "One of these fields must be present: #{inspect(fields)}"
        )
  end
end
