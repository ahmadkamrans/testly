defmodule TestlyAPI.TestIdeaResolver do
  use TestlyAPI.Resolver
  alias Testly.Accounts.User
  alias Testly.IdeaLab

  def test_ideas(%User{id: _user_id} = _user, args, %{context: %{current_user: user}}) do
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
       total_count: IdeaLab.get_ideas_count(%{filter: args[:filter]})
     }}
  end

  def toggle_test_idea_like(_parent, %{test_idea_test_id: idea_id}, %{context: %{current_user: current_user}}) do
    IdeaLab.toggle_idea_like!(IdeaLab.get_idea(idea_id), current_user)

    idea = IdeaLab.get_idea(idea_id)

    {:ok,
     %{
       test_idea_edge: %{
         node: idea,
         is_liked: IdeaLab.is_liked?(idea, current_user)
       }
     }}
  end
end
