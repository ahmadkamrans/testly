defmodule TestlyAPI.Schema.TestIdeaTypes do
  use Absinthe.Schema.Notation
  alias TestlyAPI.TestIdeaResolver

  input_object :test_idea_filter do
    field :title_cont, :string
    field :description_cont, :string
    field :category_id_eq, :string
    field :impact_rate_eq, :integer
    field :like_user_id_eq, :string
  end

  object :test_idea do
    field :id, non_null(:uuid4)
    field :title, non_null(:string)
    field :description, non_null(:string)
    field :impact_rate, non_null(:integer)
    field :cover_url, non_null(:string)
    field :category, non_null(:test_idea_category)
  end

  object :test_idea_category do
    field :id, non_null(:uuid4)
    field :name, non_null(:string)
    field :color, non_null(:string)

    field :icon_url, :string do
      resolve(fn category, _args, _ctx ->
        {:ok, ArcFixer.fix_upload_url(CategoryIcon.url({category.icon, category}))}
      end)
    end
  end

  object :test_idea_edge do
    field :node, non_null(:test_idea)
    field :is_liked, non_null(:boolean)
  end

  object :test_idea_connection do
    field :edges, non_null(list_of(non_null(:test_idea_edge)))
    field :total_count, non_null(:integer)
  end

  object :test_idea_queries do
    field :test_ideas, non_null(:test_idea_connection) do
      arg(:pagination, :pagination)
      arg(:filter, :test_idea_filter)
      resolve(&TestIdeaResolver.test_ideas/3)
    end
  end

  object :like_test_idea_payload do
    field :test_idea_edge, non_null(:test_idea_edge)
  end

  object :test_idea_mutations do
    field :toggle_test_idea_like, non_null(:like_test_idea_payload) do
      arg(:test_idea_id, non_null(:uuid4))
      resolve(&TestIdeaResolver.toggle_test_idea_like/3)
    end
  end
end
