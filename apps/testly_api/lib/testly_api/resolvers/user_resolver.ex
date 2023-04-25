defmodule TestlyAPI.UserResolver do
  use TestlyAPI.Resolver
  alias Testly.{ArcFixer, Authorizer, Accounts}
  alias Testly.Accounts.{User, Avatar}

  def update_user(%{user_params: user_params, user_id: user_id}, %{
        context: %{current_user: current_user}
      }) do
    user = Accounts.get_user(user_id)

    with {:ok, _} <- if(user, do: {:ok, user}, else: {:error, :not_found}),
         :ok <- Authorizer.authorize(:update, user, current_user) do
      case Accounts.update_user(user, user_params) do
        {:ok, %User{} = user} -> {:ok, user}
        {:error, ch} -> {:ok, ch}
      end
    else
      error -> error
    end
  end

  def update_password(%{password_params: password_params, user_id: user_id}, %{
        context: %{current_user: current_user}
      }) do
    user = Accounts.get_user(user_id)

    with {:ok, _} <- if(user, do: {:ok, user}, else: {:error, :not_found}),
         :ok <- Authorizer.authorize(:update_password, user, current_user) do
      case Accounts.update_user_password(user, password_params) do
        :ok -> {:ok, user}
        {:error, ch} -> {:ok, ch}
      end
    else
      error -> error
    end
  end

  def user_avatar_url(user, args, _resolution) do
    {:ok, ArcFixer.fix_upload_url(Avatar.url({user.avatar, user}, args.version))}
  end
end
