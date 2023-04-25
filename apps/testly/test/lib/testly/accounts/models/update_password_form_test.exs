defmodule Testly.Accounts.UpdatePasswordFormTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias Testly.Accounts.UpdatePasswordForm
  alias Testly.Accounts.User

  describe "changeset/4" do
    test "wneh passwords are equal" do
      assert true ===
               UpdatePasswordForm.changeset(
                 %UpdatePasswordForm{},
                 %{
                   current_password: "11111111",
                   new_password: "22222222"
                 },
                 %User{encrypted_password: "11111111"},
                 fn _, _ -> true end
               ).valid?
    end

    test "wneh passwords are not equal" do
      assert %Changeset{valid?: false, errors: [current_password: {"is wrong", []}]} =
               UpdatePasswordForm.changeset(
                 %UpdatePasswordForm{},
                 %{
                   current_password: "11111111",
                   new_password: "22222222"
                 },
                 %User{encrypted_password: "33333333"},
                 fn _, _ -> false end
               )
    end
  end
end
