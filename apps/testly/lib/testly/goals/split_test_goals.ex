# defmodule Testly.SplitTestGoals do
#   alias Testly.Repo
#   alias Testly.Goals.{SplitTestGoal, Goal, PathGoal}
#   alias Ecto.Changeset

#   @spec get_goal(String.t()) :: PathGoal.t() | nil
#   def get_goal(id) do
#     SplitTestGoal.from_goals
#     |> Repo.get(id)
#     |> Goal.to_type_goal
#   end

#   @spec get_goals(String.t()) :: [PathGoal.t()]
#   def get_goals(split_test_id) do
#     SplitTestGoal.from_goals
#     |> SplitTestGoal.where_split_test_id(split_test_id)
#     |> Repo.all()
#     |> Enum.map(&Goal.to_type_goal/1)
#   end

#   @spec create_goal(String.t(), map()) :: {:ok, PathGoal.t()} | {:error, Changeset.t()}
#   def create_goal(split_test_id, params) do
#     case Goal.changeset(split_test_id, params) do
#       %Changeset{valid?: true} = changeset ->
#         goal =
#           changeset
#           |> Changeset.apply_changes()
#           |> SplitTestGoal.to_split_test_goal
#           |> Repo.insert!
#           |> Goal.to_type_goal

#         # convert_goals([g.id], visits)

#         {:ok}

#       %Changeset{valid?: false} = changeset ->
#         {:error, changeset}
#     end
#   end

#   @spec update_goal(PathGoal.t(), map()) :: {:ok, PathGoal.t()} | {:error, Changeset.t()}
#   def update_goal(goal, params) do
#     case goal.__struct__.changeset(goal, params) do
#       %Changeset{valid?: true} = changeset ->
#         changeset
#         |> Changeset.apply_changes()
#         |> SplitTestGoal.to_split_test_goal
#         |> Repo.update!
#         |> Goal.to_type_goal

#       %Changeset{valid?: false} = changeset ->
#         {:error, changeset}
#     end
#   end

#   @spec delete_goal(PathGoal.t()) :: :ok
#   def delete_goal(goal) do
#     goal
#     |> SplitTestGoal.to_split_test_goal
#     |> Repo.delete!()

#     :ok
#   end

#   # @spec convert_goals([PathGoal.t()])
#   # def convert_goals(goals, visits) do
#   #   visits
#   #   |> Stream.chunk_every(500)
#   #   |> Stream.map(fn chunked_session_recordings ->
#   #     for goal <- goals,
#   #         session_recording <- chunked_session_recordings,
#   #         Goal.check_conversion(goal, session_recording) do
#   #       %{split_test_goal_id: goal.id, split_test_variation_visit_id: session_recording.id}
#   #     end
#   #   end)
#   #   |> Stream.map(fn goal_session_recording_data ->
#   #     Repo.insert_all(SpliTestGoalConversion, goal_session_recording_data, on_conflict: :nothing)
#   #   end)
#   #   |> Stream.run()

#   #   :ok
#   # end
# end
