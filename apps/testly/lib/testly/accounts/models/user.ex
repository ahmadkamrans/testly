defmodule Testly.Accounts.User do
  use Testly.Schema
  use Arc.Ecto.Schema
  import Ecto.Query

  alias __MODULE__
  alias Ecto.Changeset
  alias Testly.Accounts.{RegistrationForm, ThirdPartyRegistrationForm, UpdatePasswordForm, Avatar}

  @type t :: %__MODULE__{
          full_name: String.t(),
          email: String.t(),
          encrypted_password: String.t() | nil,
          facebook_identifier: String.t() | nil,
          reset_password_token: String.t() | nil,
          reset_password_generated_at: DateTime.t() | nil,
          company_name: String.t() | nil,
          phone: String.t() | nil
        }

  schema "users" do
    field :full_name, :string
    field :email, :string
    field :encrypted_password, :string
    field :facebook_identifier, :string
    field :reset_password_token, :string
    field :reset_password_generated_at, :utc_datetime
    field :is_admin, :boolean, default: false

    field :company_name, :string
    field :phone, :string

    field :avatar, Avatar.Type
    field :avatar_url, :string, virtual: true

    timestamps()
  end

  def update_changeset(schema, params, is_admin \\ false) do
    schema
    |> cast(params, [:full_name, :company_name, :phone] ++ if(is_admin, do: [:email, :is_admin], else: []))
    |> cast_attachments(params, [:avatar])
    |> validate_required([:full_name])
  end

  def reset_password_token_changeset(schema) do
    schema
    |> Changeset.change(%{
      reset_password_token: generate_reset_password_token(),
      reset_password_generated_at: DateTime.truncate(DateTime.utc_now(), :second)
    })
  end

  def reset_password_changeset(schema, form, encrypt) do
    schema
    |> Changeset.change(%{
      reset_password_token: nil,
      reset_password_generated_at: nil,
      encrypted_password: encrypt.(form.password)
    })
  end

  def update_password_changeset(schema, %UpdatePasswordForm{new_password: new_password}, encrypt) do
    schema
    |> Changeset.change(%{
      encrypted_password: encrypt.(new_password)
    })
  end

  def register_changeset(schema, %RegistrationForm{} = form, encrypt) do
    schema
    |> change(%{
      full_name: form.full_name,
      email: form.email,
      encrypted_password: encrypt.(form.password),
      company_name: form.company_name,
      is_admin: form.is_admin
    })
  end

  def register_changeset(schema, %ThirdPartyRegistrationForm{} = form) do
    schema
    |> change(%{
      full_name: form.full_name,
      email: form.email,
      facebook_identifier: form.facebook_identifier
    })
  end

  def from_user do
    from(u in User, as: :user)
  end

  def where_reset_password_token(query, value) do
    where(query, [user: u], u.reset_password_token == ^value)
  end

  def where_reset_password_generated_at_bigger_than(query, value) do
    where(query, [user: u], u.reset_password_generated_at >= ^value)
  end

  defp generate_reset_password_token(length \\ 64) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
