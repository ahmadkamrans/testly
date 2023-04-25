# defmodule Testly.Projects.ProjectForm do
#   use Ecto.Schema

#   import Ecto.Changeset

#   alias Ecto.Changeset
#   alias Testly.Projects.Changeset.DomainValidator
#   alias Testly.Projects.Project

#   @type t :: %__MODULE__{
#           domain: String.t(),
#           member_id: String.t()
#         }

#   embedded_schema do
#     field :domain, :string, default: ""
#     field :owner_id, Ecto.UUID, default: ""
#   end

#   @spec to_project(t(), map(), DomainValidator.domain_already_taken?()) ::
#           {:ok, Project.t()} | {:error, Changeset.t()}
#   def to_project(form, attrs, domain_already_taken?) do
#     result = changeset(form, attrs, domain_already_taken?)

#     case result do
#       %Changeset{valid?: true} = ch ->
#         form = Changeset.apply_changes(ch)

#         {:ok,
#          %Project{
#            domain: form.domain,
#            member_id: form.member_id
#          }}

#       %Changeset{valid?: false} = ch ->
#         {:error, ch}
#     end
#   end

#   @spec changeset(t(), map(), DomainValidator.domain_already_taken?()) :: Changeset.t()
#   defp changeset(form, attrs, domain_already_taken?) do
#     form
#     |> cast(attrs, [:domain, :member_id])
#     |> validate_required([:domain, :member_id])
#     |> DomainValidator.validate(domain_already_taken?)
#   end
# end
