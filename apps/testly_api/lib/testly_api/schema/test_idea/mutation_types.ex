defmodule TestlyAPI.Schema.TestIdea.MutationTypes do
  use Absinthe.Schema.Notation

  alias Testly.IdeaLab

  object :like_test_idea_payload do
    field :test_idea_edge, non_null(:user_test_idea_edge)
  end

  object :test_idea_mutations do
    field :toggle_test_idea_like, non_null(:like_test_idea_payload) do
      arg(:test_idea_test_id, non_null(:uuid4))

      resolve(fn %{test_idea_test_id: idea_id}, %{context: %{current_account_user: current_account_user}} ->
        IdeaLab.toggle_idea_like!(IdeaLab.get_idea(idea_id), current_account_user)

        idea = IdeaLab.get_idea(idea_id)

        {:ok,
         %{
           test_idea_edge: %{
             node: idea,
             is_liked: IdeaLab.is_liked?(idea, current_account_user)
           }
         }}
      end)
    end
  end
end
