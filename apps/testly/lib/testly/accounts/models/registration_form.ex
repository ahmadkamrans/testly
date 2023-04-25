defmodule Testly.Accounts.RegistrationForm do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Testly.Accounts.Changeset.{EmailValidator, PasswordValidator}

  @type t :: %__MODULE__{
          full_name: String.t(),
          email: String.t(),
          password: String.t(),
          tos_accepted: boolean()
        }

  embedded_schema do
    field :full_name, :string, default: ""
    field :email, :string, default: ""
    field :password, :string, default: ""
    field :tos_accepted, :boolean, default: false
  end

  @spec changeset(t(), map(), EmailValidator.was_email_taken()) :: Changeset.t()
  def changeset(form, params, was_email_taken?) do
    form
    |> cast(params, [:full_name, :email, :password, :tos_accepted])
    |> validate_required([:full_name, :email, :password, :tos_accepted])
    |> validate_acceptance(:tos_accepted, message: "you must accept the terms of service")
    |> EmailValidator.validate(was_email_taken?)
    |> PasswordValidator.validate(:password)
  end
end
