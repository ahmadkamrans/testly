defmodule Testly.AccountsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Accounts.{
        User, RegistrationForm, ThirdPartyRegistrationForm,
        SignInForm, ResetPasswordTokenForm, ResetPasswordForm
      }

      def user_factory do
        %User{
          email: sequence(:email, &"email-#{&1}@example.com"),
          full_name: Faker.Name.name()
        }
      end

      def registration_form_factory do
        %RegistrationForm{
          email: sequence(:email, &"email-#{&1}@example.com"),
          full_name: Faker.Name.name(),
          password: "qwerty",
          tos_accepted: true
        }
      end

      def third_party_registration_form_factory do
        %ThirdPartyRegistrationForm{
          email: sequence(:email, &"email-#{&1}@example.com"),
          full_name: Faker.Name.name(),
          facebook_identifier: "facebook_id",
          tos_accepted: true
        }
      end

      def sign_in_form_factory do
        %SignInForm{}
      end

      def reset_password_token_form_factory do
        %ResetPasswordTokenForm{}
      end

      def reset_password_form_factory do
        %ResetPasswordForm{}
      end
    end
  end
end
