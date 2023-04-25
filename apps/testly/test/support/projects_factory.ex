defmodule Testly.ProjectsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Projects.{Project, User}

      def project_factory do
        %Project{
          user: build(:project_user),
          domain: sequence(:domain, &"example#{&1}.com"),
          is_deleted: false
        }
      end

      def project_user_factory do
        %User{
          full_name: Faker.Name.name()
        }
      end
    end
  end
end
