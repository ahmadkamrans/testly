defmodule TestlyAPI.Schema.Project.MutationTypes do
  use Absinthe.Schema.Notation

  import(Kronky.Payload, only: :functions)
  import(TestlyAPI.Schema.Payload)

  alias Testly.Projects
  alias Testly.Authorizer
  alias Testly.Projects.Project

  payload_object(:project_payload, :project)

  input_object :project_params do
    field(:domain, :string)
    field(:is_recording_enabled, :boolean, default_value: true)
  end

  object :project_mutations do
    field :create_project, type: :project_payload do
      arg(:project_params, :project_params)

      resolve(fn %{project_params: project_params}, %{context: %{current_project_user: current_project_user}} ->
        case Projects.create_project(current_project_user.id, project_params) do
          {:ok, %Project{} = project} -> {:ok, project}
          {:error, ch} -> {:ok, ch}
        end
      end)

      middleware(&build_payload/2)
    end

    field :delete_project, :project do
      arg(:id, non_null(:uuid4))

      resolve(fn %{id: project_id}, %{context: %{current_project_user: current_project_user}} ->
        project = Projects.get_project(project_id)

        with {:ok, _} <- if(project, do: {:ok, project}, else: {:error, :not_found}),
             :ok <- Authorizer.authorize(:delete, project, current_project_user),
             :ok <- Projects.delete_project(project) do
          {:ok, project}
        else
          error -> error
        end
      end)
    end

    field :update_project, :project_payload do
      arg(:id, non_null(:uuid4))
      arg(:project_params, :project_params)

      resolve(fn %{project_params: project_params, id: project_id},
                 %{context: %{current_project_user: current_project_user}} ->
        project = Projects.get_project(project_id)

        with {:ok, _} <- if(project, do: {:ok, project}, else: {:error, :not_found}),
             :ok <- Authorizer.authorize(:update, project, current_project_user) do
          case Projects.update_project(project, project_params) do
            {:ok, %Project{} = project} -> {:ok, project}
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
