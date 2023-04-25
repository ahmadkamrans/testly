defmodule TestlyAPI.Schema.UserType do
  use Absinthe.Schema.Notation

  alias Testly.Projects.User
  alias Testly.Projects
  alias Testly.Accounts.Avatar
  alias Testly.ArcFixer

  enum(:user_avatar_type, values: [:original, :thumb])

  object :projects_connection do
    field :nodes, non_null(list_of(non_null(:project)))

    field :total_records, non_null(:integer)
  end

  object :user do
    field :id, non_null(:uuid4)
    field :full_name, non_null(:string)
    field :email, non_null(:string)
    field(:company_name, :string)
    field(:phone, :string)

    field :avatar_url, :string do
      arg(:version, non_null(:user_avatar_type), default_value: :thumb)

      resolve(fn user, args, _resolution ->
        {:ok, ArcFixer.fix_upload_url(Avatar.url({user.avatar, user}, args.version))}
      end)
    end

    field :relevant_project, :project do
      resolve(fn %User{id: user_id}, _args, _resolution ->
        {:ok, Projects.get_relevant_project(user_id)}
      end)
    end

    field :projects, non_null(:projects_connection) do
      resolve(fn %User{id: user_id}, _args, _resolution ->
        {:ok,
         %{
           nodes: Projects.get_projects(user_id),
           total_records: 0
         }}
      end)
    end

    field :project, :project do
      arg(:id, non_null(:uuid4))

      resolve(fn %{id: id}, _resolution ->
        {:ok, Projects.get_project(id)}
      end)
    end

    import_fields(:user_test_idea_fields)
  end
end
