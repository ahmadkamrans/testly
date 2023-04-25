defmodule TestlyAPI.Schema do
  use Absinthe.Schema

  import_types(TestlyAPI.Schema.Types.UUID4)
  import_types(TestlyAPI.Schema.Types.JSON)
  import_types(Absinthe.Type.Custom)
  import_types(TestlyAPI.Schema.Types)
  import_types(TestlyAPI.Schema.TestIdeaTypes)
  import_types(TestlyAPI.Schema.TestIdea.MutationTypes)
  import_types(TestlyAPI.Schema.UserType)
  import_types(TestlyAPI.Schema.User.MutationTypes)
  import_types(TestlyAPI.Schema.GoalTypes)
  import_types(TestlyAPI.Schema.Goal.MutationTypes)
  import_types(TestlyAPI.Schema.Goal.PathGoalTypes)
  import_types(TestlyAPI.Schema.HeatmapTypes)
  import_types(TestlyAPI.Schema.SessionRecordingType)
  import_types(TestlyAPI.Schema.SessionRecording.DeviceType)
  import_types(TestlyAPI.Schema.SessionRecording.LocationType)
  import_types(TestlyAPI.Schema.SessionRecording.EventType)
  import_types(TestlyAPI.Schema.SessionRecording.PageType)
  import_types(TestlyAPI.Schema.SplitTestTypes)
  import_types(TestlyAPI.Schema.SplitTest.MutationTypes)
  import_types(TestlyAPI.Schema.FeedbackPollTypes)
  import_types(TestlyAPI.Schema.FeedbackPoll.MutationTypes)
  import_types(TestlyAPI.Schema.ProjectTypes)
  import_types(TestlyAPI.Schema.Project.MutationTypes)
  import_types(Kronky.ValidationMessageTypes)
  import_types(Absinthe.Plug.Types)

  query do
    import_fields(:root_query_test_idea_fields)
    import_fields(:root_test_idea_fields)

    field :current_user, :user do
      resolve(fn _parent,
                 %{
                   context: %{
                     current_account_user: current_account_user,
                     current_project_user: current_project_user
                   }
                 } ->
        {:ok, Map.merge(current_account_user, current_project_user)}
      end)
    end

    field :page_categories, non_null(list_of(non_null(:page_category))) do
      resolve(fn _parent, _ ->
        {:ok, Testly.SplitTests.get_page_categories()}
      end)
    end

    field :page_types, non_null(list_of(non_null(:page_type))) do
      resolve(fn _parent, _ ->
        {:ok, Testly.SplitTests.get_page_types()}
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
end
