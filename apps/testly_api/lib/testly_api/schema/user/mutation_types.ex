defmodule TestlyAPI.Schema.User.MutationTypes do
  use Absinthe.Schema.Notation

  import(Kronky.Payload, only: :functions)
  import(TestlyAPI.Schema.Payload)

  alias Testly.Authorizer
  alias Testly.Accounts
  alias Testly.Accounts.User

  payload_object(:user_payload, :user)

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

  object :user_mutations do
    field :update_user, non_null(:user_payload) do
      arg(:user_id, non_null(:uuid4))
      arg(:user_params, non_null(:user_params))

      resolve(fn %{user_params: user_params, user_id: user_id},
                 %{context: %{current_account_user: current_account_user}} ->
        user = Accounts.get_user(user_id)

        with {:ok, _} <- if(user, do: {:ok, user}, else: {:error, :not_found}),
             :ok <- Authorizer.authorize(:update, user, current_account_user) do
          case Accounts.update_user(user, user_params) do
            {:ok, %User{} = user} -> {:ok, user}
            {:error, ch} -> {:ok, ch}
          end
        else
          error -> error
        end
      end)

      middleware(&build_payload/2)
    end

    field :update_password, non_null(:user_payload) do
      arg(:user_id, non_null(:uuid4))
      arg(:password_params, non_null(:update_password_params))

      resolve(fn %{password_params: password_params, user_id: user_id},
                 %{context: %{current_account_user: current_account_user}} ->
        user = Accounts.get_user(user_id)

        with {:ok, _} <- if(user, do: {:ok, user}, else: {:error, :not_found}),
             :ok <- Authorizer.authorize(:update_password, user, current_account_user) do
          case Accounts.update_user_password(user, password_params) do
            :ok -> {:ok, user}
            {:error, ch} -> {:ok, ch}
          end
        else
          error -> error
        end
      end)

      middleware(&build_payload/2)
    end
  end
end
