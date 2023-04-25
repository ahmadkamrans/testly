defmodule TestlyAPI.Schema do
  use Absinthe.Schema

  alias Testly.{SplitTests}

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(Kronky.ValidationMessageTypes)
  import_types(TestlyAPI.Schema.Types.UUID4)
  import_types(TestlyAPI.Schema.Types.JSON)
  import_types(TestlyAPI.Schema.Types)
  import_types(TestlyAPI.Schema.TestIdeaTypes)
  import_types(TestlyAPI.Schema.UserType)
  import_types(TestlyAPI.Schema.GoalTypes)
  import_types(TestlyAPI.Schema.HeatmapTypes)
  import_types(TestlyAPI.Schema.SessionRecordingTypes)
  import_types(TestlyAPI.Schema.SplitTestTypes)
  import_types(TestlyAPI.Schema.FeedbackPollTypes)
  import_types(TestlyAPI.Schema.ProjectTypes)

  query do
    import_fields(:test_idea_queries)
    import_fields(:split_test_page_category_queries)
    import_fields(:split_test_page_type_queries)

    field :current_user, :user do
      middleware(TestlyAPI.AuthenticationMiddleware)

      resolve(fn _parent, %{context: %{current_user: current_user}} ->
        {:ok, current_user}
      end)
    end
  end

  mutation do
    import_fields(:project_mutations)
    import_fields(:goal_mutations)
    import_fields(:split_test_mutations)
    import_fields(:feedback_poll_mutations)
    import_fields(:test_idea_mutations)
    import_fields(:user_mutations)
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  def dataloader() do
    Dataloader.new()
    |> Dataloader.add_source(SplitTests, SplitTests.data_source())
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
