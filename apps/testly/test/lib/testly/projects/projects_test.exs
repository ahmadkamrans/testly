defmodule Testly.ProjectsTest do
  use Testly.DataCase
  import Testly.DataFactory

  alias Ecto.Changeset
  alias Testly.Projects
  alias Testly.Projects.Project

  describe "#get_project/1" do
    test "works" do
      project = insert(:project)

      response = Projects.get_project(project.id)

      assert %Project{} = response
    end
  end

  describe "#create_project/2" do
    test "valid params" do
      user = insert(:user)
      params = string_params_for(:project)

      response = Projects.create_project(user.id, params)

      assert {:ok, %Project{}} = response
    end

    test "invalid params" do
      user = insert(:user)
      params = %{}

      response = Projects.create_project(user.id, params)

      assert {:error, %Ecto.Changeset{}} = response
    end
  end

  describe "#update_project/2" do
    test "valid" do
      project = insert(:project)
      params = string_params_for(:project)

      response = Projects.update_project(project, params)

      assert {:ok, %Project{}} = response
    end

    test "invalid" do
      project = insert(:project)
      params = %{domain: ""}

      response = Projects.update_project(project, params)

      assert {:error, %Changeset{}} = response
    end
  end

  describe "delete_project/1" do
    test "deletes project" do
      %Project{id: project_id} = project = insert(:project)

      :ok = Projects.delete_project(project)

      assert Projects.get_project(project_id) === nil
    end
  end
end
