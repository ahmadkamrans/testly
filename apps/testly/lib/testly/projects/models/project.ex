defmodule Testly.Projects.Project do
  use Testly.Schema
  import Ecto.Query

  alias __MODULE__

  @type t :: %__MODULE__{
          id: Schema.pk(),
          user_id: Schema.pk(),
          domain: String.t(),
          uploaded_script_hash: String.t(),
          is_recording_enabled: boolean,
          is_tracking_code_installed: boolean,
          is_deleted: boolean
        }

  schema "projects" do
    field :user_id, Ecto.UUID
    field :domain, :string
    field :uploaded_script_hash, :string
    field :is_recording_enabled, :boolean
    field :is_tracking_code_installed, :boolean
    field :is_deleted, :boolean, default: false

    timestamps()
  end

  def create_changeset(schema, params) do
    schema
    |> cast(params, [:domain, :is_recording_enabled, :is_deleted])
    |> validate_required([:domain])
    |> unique_constraint(:domain, name: :projects_domain_user_id_index)
  end

  def update_changeset(schema, params) do
    create_changeset(schema, params)
  end

  def from_project do
    from(p in Project, as: :project)
  end

  def where_is_not_deleted(query) do
    where(query, [project: p], p.is_deleted == false)
  end

  def where_user(query, user_id) do
    where(query, [project: p], p.user_id == ^user_id)
  end

  def order_by_created_at_desc(query) do
    order_by(query, [project: p], desc: :created_at)
  end
end
