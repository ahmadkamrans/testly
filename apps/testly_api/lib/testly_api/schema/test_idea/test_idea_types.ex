defmodule TestlyAPI.Schema.TestIdeaTypes do
  use Absinthe.Schema.Notation

  alias Testly.Projects.User
  alias Testly.IdeaLab
  alias Testly.IdeaLab.CategoryIcon
  alias Testly.ArcFixer

  object :test_idea do
    field :id, non_null(:uuid4)
    field :title, non_null(:string)
    field :description, non_null(:string)
    field :impact_rate, non_null(:integer)
    field :cover_url, non_null(:string)
    field :category, non_null(:test_idea_category)
  end

  object :test_idea_category do
    field :id, non_null(:string)
    field :name, non_null(:string)
    field :color, non_null(:string)

    field :icon_url, :string do
      resolve(fn category, _args, _ctx ->
        {:ok, ArcFixer.fix_upload_url(CategoryIcon.url({category.icon, category}))}
      end)
    end
  end

  object :user_test_ideas_connection do
    field :edges, non_null(list_of(non_null(:user_test_idea_edge)))
    field :total_records, non_null(:integer)
  end

  object :user_test_idea_edge do
    field :node, non_null(:test_idea)
    field :is_liked, non_null(:boolean)
  end

  input_object :test_idea_filter do
    field :title_cont, :string
    field :description_cont, :string
    field :category_id_eq, :string
    field :impact_rate_eq, :integer
    field :like_user_id_eq, :string
  end

  object :root_query_test_idea_fields do
    field :test_idea_categories, non_null(list_of(non_null(:test_idea_category))) do
      resolve(fn _user, _args, _ctx ->
        {:ok, IdeaLab.get_categories()}
      end)
    end
  end

  object :root_test_idea_fields do
    field :test_ideas, non_null(list_of(non_null(:test_idea))) do
      resolve(fn _user, _args, _ctx ->
        {:ok, IdeaLab.get_all_ideas()}
      end)
    end
  end

  object :user_test_idea_fields do
    field :test_ideas, non_null(:user_test_ideas_connection) do
      arg(:pagination, :pagination)
      arg(:filter, :test_idea_filter)

      resolve(fn %User{id: _user_id} = _user, args, %{context: %{current_account_user: user}} ->
        ideas =
          IdeaLab.get_ideas(%{
            pagination: args[:pagination],
            filter: args[:filter]
          })

        likes = IdeaLab.get_likes(user)

        edges =
          Enum.map(ideas, fn idea ->
            %{
              node: idea,
              is_liked: Enum.any?(likes, &(&1.idea_id == idea.id))
            }
          end)

        {:ok,
         %{
           edges: edges,
           total_records: IdeaLab.get_ideas_count(%{filter: args[:filter]})
         }}
      end)
    end
  end
end
