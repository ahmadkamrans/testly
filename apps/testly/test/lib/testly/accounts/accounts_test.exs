defmodule Testly.AccountsTest do
  use Testly.DataCase

  alias Testly.Accounts
  alias Testly.Accounts.{
    User,
    RegistrationForm,
    ThirdPartyRegistrationForm,
    SignInForm,
    PasswordManager,
    ResetPasswordTokenForm,
    ResetPasswordForm
  }

  describe "#get_user/1" do
    test "works" do
      user = insert(:user)

      response = Accounts.get_user(user.id)

      assert %User{} = response
    end
  end

  describe "#get_user_by_email/1" do
    test "works" do
      user = insert(:user)

      response = Accounts.get_user_by_email(user.email)

      assert %User{} = response
    end
  end

  describe "#get_unexpired_user_by_reset_password_token/1" do
    test "unexpired" do
      token = "token"

      insert(:user, %{
        reset_password_token: token,
        reset_password_generated_at: DateTime.utc_now()
      })

      response = Accounts.get_unexpired_user_by_reset_password_token(token)

      assert %User{reset_password_token: token} = response
    end

    test "expired" do
      token = "token"

      insert(:user, %{
        reset_password_token: token,
        reset_password_generated_at: Timex.shift(DateTime.utc_now(), months: -1)
      })

      response = Accounts.get_unexpired_user_by_reset_password_token(token)

      assert response == nil
    end
  end

  describe "#change_registration_form/1" do
    test "works" do
      assert %Changeset{} = Accounts.change_registration_form(%RegistrationForm{})
      assert %Changeset{} = Accounts.change_registration_form(%ThirdPartyRegistrationForm{})
    end
  end

  describe "#change_sign_in_form/1" do
    test "works" do
      assert %Changeset{} = Accounts.change_sign_in_form(%SignInForm{})
    end
  end

  describe "#change_reset_password_token_form/1" do
    test "works" do
      assert %Changeset{} = Accounts.change_reset_password_token_form(%ResetPasswordTokenForm{})
    end
  end

  describe "#change_reset_password_form/1" do
    test "works" do
      assert %Changeset{} = Accounts.change_reset_password_form(%ResetPasswordForm{})
    end
  end

  describe "#register_user/1" do
    test "valid" do
      params = string_params_for(:registration_form)

      response = Accounts.register_user(params)

      assert {:ok, %User{}} = response
    end

    test "invalid" do
      params = %{}

      response = Accounts.register_user(params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "#third_party_register_user/1" do
    test "valid" do
      params = string_params_for(:third_party_registration_form)

      response = Accounts.third_party_register_user(params)

      assert {:ok, %User{}} = response
    end

    test "invalid" do
      params = %{}

      response = Accounts.third_party_register_user(params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "#sign_in_user/1" do
    setup do
      password = "qwerty"
      user = insert(:user, encrypted_password: PasswordManager.encrypt(password))

      %{user: user, password: password}
    end

    test "valid", %{user: user, password: password} do
      params =
        string_params_for(:sign_in_form, %{
          email: user.email,
          password: password
        })

      response = Accounts.sign_in_user(params)

      assert {:ok, %SignInForm{}} = response
    end

    test "invalid" do
      params = %{}

      response = Accounts.sign_in_user(params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "#reset_password_token/1" do
    test "valid" do
      user = insert(:user)

      params =
        string_params_for(:reset_password_token_form, %{
          email: user.email
        })

      response = Accounts.reset_password_token(params)

      assert {:ok, %User{}} = response
    end

    test "invalid" do
      params = %{}

      response = Accounts.reset_password_token(params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "#reset_password/1" do
    setup do
      token = "token"

      user =
        insert(:user, %{
          reset_password_token: token,
          # DateTime.truncate(DateTime.utc_now(), :second)
          reset_password_generated_at: DateTime.utc_now()
        })

      %{user: user}
    end

    test "valid", %{user: user} do
      params =
        string_params_for(:reset_password_form, %{
          password: "qwerty"
        })

      response = Accounts.reset_password(user, params)

      assert {:ok, %User{}} = response
    end

    test "invalid", %{user: user} do
      params = %{}

      response = Accounts.reset_password(user, params)

      assert {:error, %Changeset{}} = response
    end
  end
end
