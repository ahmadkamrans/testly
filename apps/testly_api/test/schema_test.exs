defmodule TestlyAPI.SchemaTest do
  use TestlyAPI.ConnCase, async: true

  import Testly.AccountsFactory

  # describe "current_user" do
  #   test "resolves", %{conn: conn} do
  #     user = insert(:user)

  #     query = """
  #     {
  #       currentUser {
  #         id
  #       }
  #     }
  #     """

  #     response =
  #       conn
  #       |> auth_user(user.id)
  #       |> post("/graphql", %{query: query})
  #       |> json_response(200)

  #     assert response == %{
  #              "data" => %{
  #                "currentUser" => %{"id" => user.id}
  #              }
  #            }
  #   end
  # end
end
