defmodule Testly.ProjectsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Projects.{Project, User}

      def project_factory do
        %{id: user_id} = insert(:user)

        %Project{
          user_id: user_id,
          domain: sequence(:domain, &"example#{&1}.com"),
          is_deleted: false
        }
      end
    end
  end
end
