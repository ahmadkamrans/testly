defmodule TestlyAPI.Schema.UserType do
  use TestlyAPI.Schema.Notation

  alias TestlyAPI.UserResolver

  enum(:user_avatar_type, values: [:original, :thumb])

  input_object :user_params do
    field(:full_name, :string)
    field(:company_name, :string)
    field(:phone, :string)
    field(:avatar, :upload)
  end

  input_object :update_password_params do
    field(:current_password, non_null(:string))
    field(:new_password, non_null(:string))
  end

  object :user do
    field :id, non_null(:uuid4)
    field :full_name, non_null(:string)
    field :email, non_null(:string)
    field(:company_name, :string)
    field(:phone, :string)

    field :avatar_url, :string do
      arg(:version, non_null(:user_avatar_type), default_value: :thumb)
      resolve(&UserResolver.user_avatar_url/3)
    end

    import_fields(:project_queries)
    import_fields(:test_idea_queries)
  end

  payload_object(:user_payload, :user)

  object :user_mutations do
    field :update_user, non_null(:user_payload) do
      arg(:user_id, non_null(:uuid4))
      arg(:user_params, non_null(:user_params))
      resolve(&UserResolver.update_user/2)
      middleware(&build_payload/2)
    end

    field :update_password, non_null(:user_payload) do
      arg(:user_id, non_null(:uuid4))
      arg(:password_params, non_null(:update_password_params))
      resolve(&UserResolver.update_password/2)
      middleware(&build_payload/2)
    end
  end
end
