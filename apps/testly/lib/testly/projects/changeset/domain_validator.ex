# defmodule Testly.Projects.Changeset.DomainValidator do
#   import Ecto.Changeset

#   alias Ecto.Changeset

#   @type domain_already_taken? :: (domain :: String.t(), user_id :: String.t() -> boolean())

#   @spec validate(Changeset.t(), domain_already_taken?()) :: Changeset.t()
#   def validate(%Changeset{} = ch, domain_already_taken?) do
#     ch
#     |> validate_length(:domain, min: 5)
#     |> not_taken(domain_already_taken?)
#   end

#   @spec not_taken(Changeset.t(), domain_already_taken?()) :: Changeset.t()
#   defp not_taken(ch, domain_already_taken?) do
#     domain = get_field(ch, :domain)
#     user_id = get_field(ch, :user_id)
#     was_taken = (domain && user_id && domain_already_taken?.(domain, user_id)) || false

#     if was_taken do
#       add_error(ch, :domain, "has already been taken")
#     else
#       ch
#     end
#   end
# end
