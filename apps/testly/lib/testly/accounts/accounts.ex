defmodule Testly.Accounts do
  defmodule Behaviour do
    alias Ecto.Changeset

    alias Testly.Accounts.{
      User,
      RegistrationForm,
      ThirdPartyRegistrationForm,
      SignInForm,
      ResetPasswordTokenForm
    }

    @callback paginate_users(map()) :: {:ok, map()} | {:error, map()}
    @callback get_unexpired_user_by_reset_password_token(String.t()) :: User.t() | nil
    @callback get_user_by_email(String.t()) :: User.t() | nil
    @callback get_admin_by_email(String.t()) :: User.t() | nil
    @callback get_user_by_facebook_identifier(String.t()) :: User.t() | nil
    @callback get_user(String.t()) :: User.t() | nil
    @callback get_user!(String.t()) :: User.t() | nil
    @callback change_registration_form(RegistrationForm.t() | ThirdPartyRegistrationForm.t()) ::
                Changeset.t()
    @callback change_sign_in_form(SignInForm.t()) :: Changeset.t()
    @callback change_reset_password_token_form(ResetPasswordTokenForm.t()) :: Changeset.t()
    @callback change_reset_password_form(ResetPasswordForm.t()) :: Changeset.t()
    @callback change_user(User.t()) :: Changeset.t()
    @callback register_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
    @callback third_party_register_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
    @callback sign_in_user(map()) :: {:ok, SignInForm.t()} | {:error, Changeset.t()}
    @callback sign_in_admin(map()) :: {:ok, SignInForm.t()} | {:error, Changeset.t()}
    @callback reset_password_token(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
    @callback reset_password(User.t(), map()) :: {:ok, User.t()} | {:error, Changeset.t()}
    @callback update_user(User.t(), map(), boolean()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
    @callback update_user_password(User.t(), map()) :: :ok | {:error, Ecto.Changeset.t()}
    @callback delete_user!(User.t()) :: User.t()
  end

  @behaviour Behaviour

  alias Testly.{Repo, Pagination}
  alias Ecto.Changeset

  alias Testly.Accounts.{
    User,
    RegistrationForm,
    SignInForm,
    ThirdPartyRegistrationForm,
    PasswordManager,
    ResetPasswordTokenForm,
    ResetPasswordForm,
    SendWelcomeEmailWorker,
    SendResetPasswordEmailWorker,
    UpdatePasswordForm,
    UserQuery,
    UserFilter,
    UserOrder
  }

  @config Application.fetch_env!(:testly, __MODULE__)
  @reset_password_token_expiration_hours Keyword.fetch!(
                                           @config,
                                           :reset_password_token_expiration_hours
                                         )

  @impl true
  def paginate_users(params \\ %{}) do
    filter_changeset = UserFilter.changeset(%UserFilter{}, params[:filter] || params["filter"] || %{})
    pagination_changeset = Pagination.changeset(%Pagination{}, params[:pagination] || params["pagination"] || %{})
    order_changeset = UserOrder.changeset(%UserOrder{}, params[:order] || params["order"] || %{})

    with %Changeset{valid?: true} <- filter_changeset,
         %Changeset{valid?: true} <- pagination_changeset,
         %Changeset{valid?: true} <- order_changeset do
      filter = Changeset.apply_changes(filter_changeset)
      order = Changeset.apply_changes(order_changeset)
      pagination = Changeset.apply_changes(pagination_changeset)

      page =
        UserQuery.from_user()
        |> UserFilter.query(filter)
        |> UserOrder.query(order)
        |> Repo.scrivener_paginate(pagination)

      {:ok,
       %{
         pagination: pagination,
         filter: filter,
         order: order,
         entries: page.entries,
         total_pages: page.total_pages,
         total_entries: page.total_entries
       }}
    else
      _invalid_changeset ->
        {:error,
         %{
           pagination: pagination_changeset,
           filter: filter_changeset,
           order: order_changeset
         }}
    end
  end

  @impl true
  def get_unexpired_user_by_reset_password_token(token) do
    time_ago = Timex.shift(DateTime.utc_now(), hours: -@reset_password_token_expiration_hours)

    User.from_user()
    |> User.where_reset_password_token(token)
    |> User.where_reset_password_generated_at_bigger_than(time_ago)
    |> Repo.one()
  end

  @impl true
  def get_user_by_email(email) do
    Repo.get_by(User, %{email: email})
  end

  @impl true
  def get_admin_by_email(email) do
    Repo.get_by(User, %{email: email, is_admin: true})
  end

  @impl true
  def get_user_by_facebook_identifier(facebook_identifier) do
    Repo.get_by(User, %{facebook_identifier: facebook_identifier})
  end

  @impl true
  def get_user(id) do
    Repo.get(User, id)
  end

  @impl true
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @impl true
  def delete_user!(user) do
    Repo.delete!(user)
  end

  @impl true
  def update_user(user, params, is_admin \\ false) do
    user
    |> User.update_changeset(params, is_admin)
    |> Repo.update()
  end

  @impl true
  def update_user_password(user, params) do
    %UpdatePasswordForm{}
    |> UpdatePasswordForm.changeset(params, user, &PasswordManager.check?/2)
    |> case do
      %Changeset{valid?: true} = ch ->
        user
        |> User.update_password_changeset(Changeset.apply_changes(ch), &PasswordManager.encrypt/1)
        |> Repo.update!()

        :ok

      not_valid ->
        {:error, not_valid}
    end
  end

  @impl true
  def change_user(%User{} = user) do
    Changeset.change(user)
  end

  @impl true
  def change_registration_form(%RegistrationForm{} = form) do
    Changeset.change(form)
  end

  @impl true
  def change_registration_form(%ThirdPartyRegistrationForm{} = form) do
    Changeset.change(form)
  end

  @impl true
  def change_sign_in_form(%SignInForm{} = form) do
    Changeset.change(form)
  end

  @impl true
  def change_reset_password_token_form(%ResetPasswordTokenForm{} = form) do
    Changeset.change(form)
  end

  @impl true
  def change_reset_password_form(%ResetPasswordForm{} = form) do
    Changeset.change(form)
  end

  @impl true
  def register_user(params, is_admin_allowed \\ false) do
    case RegistrationForm.changeset(%RegistrationForm{}, params, &was_email_taken?/1, is_admin_allowed) do
      %Changeset{valid?: true} = changeset ->
        form = Changeset.apply_changes(changeset)

        user =
          %User{}
          |> User.register_changeset(form, &PasswordManager.encrypt/1)
          |> Repo.insert!()

        SendWelcomeEmailWorker.enqueue(user.email, user.full_name, user.email)

        {:ok, user}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def third_party_register_user(params) do
    case ThirdPartyRegistrationForm.changeset(
           %ThirdPartyRegistrationForm{},
           params,
           &was_email_taken?/1
         ) do
      %Changeset{valid?: true} = changeset ->
        form = Changeset.apply_changes(changeset)

        user =
          %User{}
          |> User.register_changeset(form)
          |> Repo.insert!()

        SendWelcomeEmailWorker.enqueue(user.email, user.full_name, user.email)

        {:ok, user}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def sign_in_user(params) do
    case SignInForm.changeset(
           %SignInForm{},
           params,
           &get_user_by_email/1,
           &PasswordManager.check?/2
         ) do
      %Changeset{valid?: true} = changeset ->
        {:ok, Changeset.apply_changes(changeset)}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def sign_in_admin(params) do
    case SignInForm.changeset(
           %SignInForm{},
           params,
           &get_admin_by_email/1,
           &PasswordManager.check?/2
         ) do
      %Changeset{valid?: true} = changeset ->
        {:ok, Changeset.apply_changes(changeset)}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def reset_password_token(params) do
    case ResetPasswordTokenForm.changeset(%ResetPasswordTokenForm{}, params, &get_user_by_email/1) do
      %Changeset{valid?: true} = changeset ->
        form = Changeset.apply_changes(changeset)

        user =
          get_user_by_email(form.email)
          |> User.reset_password_token_changeset()
          |> Repo.update!()

        SendResetPasswordEmailWorker.enqueue(
          user.email,
          user.full_name,
          user.reset_password_token
        )

        {:ok, user}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def reset_password(user, params) do
    case ResetPasswordForm.changeset(%ResetPasswordForm{}, params) do
      %Changeset{valid?: true} = changeset ->
        form = Changeset.apply_changes(changeset)

        user =
          user
          |> User.reset_password_changeset(form, &PasswordManager.encrypt/1)
          |> Repo.update!()

        {:ok, user}

      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  defp was_email_taken?(email) do
    get_user_by_email(email) != nil
  end
end
