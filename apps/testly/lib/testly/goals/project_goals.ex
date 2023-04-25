# defmodule Testly.Goals.ProjectGoals do
#   alias Testly.Repo
#   alias Testly.Goals.{Goal, PathGoal, ProjectGoal, ProjectGoalConversion}
#   alias Testly.SessionRecordings.{SessionRecording, Page}

#   import Ecto.Query, only: [from: 2]
#   alias Ecto.Changeset
#   alias Ecto.Multi

#   @spec goal_conversions_count(String.t()) :: integer()
#   def goal_conversions_count(goal_id) do
#     query = from(p_g_c in ProjectGoalConversion, where: p_g_c.goal_id == ^goal_id)
#     Repo.aggregate(query, :count, :session_recording_id)
#   end

#   @spec goals_count(String.t()) :: integer
#   def goals_count(project_id) do
#     ProjectGoal.from_goals()
#     |> ProjectGoal.where_project_id(project_id)
#     |> Repo.aggregate(:count, :id)
#   end

#   @spec get_goals(String.t()) :: [PathGoal.t()]
#   def get_goals(project_id) do
#     ProjectGoal.from_goals()
#     |> ProjectGoal.where_project(project_id)
#     |> ProjectGoal.order_by_created_at_desc()
#     |> Repo.all()
#     |> Enum.map(&Goal.to_type_goal/1)
#   end

#   @spec get_goal(String.t()) :: PathGoal.t() | nil
#   def get_goal(id) do
#     ProjectGoal
#     |> Repo.get(id)
#     |> Goal.to_type_goal
#   end

#   @spec create_goal(String.t(), map()) :: {:ok, PathGoal.t()} | {:error, Ecto.Changeset.t()}
#   def create_goal(project_id, params) do
#     case Goal.changeset(project_id, params) do
#       %Changeset{valid?: true} = changeset ->
#         goal =
#           changeset
#           |> Changeset.apply_changes()
#           |> ProjectGoal.to_project_goal
#           |> Repo.insert!
#           |> Goal.to_type_goal

#         # TODO: reach worker

#       {:ok, goal}
#       %Changeset{valid?: false} = changeset ->
#         {:error, changeset}
#     end
#   end

#   @spec update_goal(PathGoal.t(), map()) :: {:ok, PathGoal.t()} | {:error, Ecto.Changeset.t()}
#   def update_goal(goal, params) do
#     case Goal.changeset(goal.assoc_id, params) do
#       %Changeset{valid?: true} = changeset ->
#         project_goal =
#             changeset
#             |> Changeset.apply_changes()
#             |> ProjectGoal.to_project_goal

#         {:ok, %{project_goal: project_goal}} =
#           Multi.new()
#           |> Multi.update(:project_goal, project_goal)
#           |> Multi.delete_all(:conversions, Ecto.assoc(project_goal, :conversions))
#           |> Repo.transaction()

#           # TODO: reach worker

#         {:ok, Goal.to_type_goal(project_goal)}

#       %Changeset{valid?: false} = changeset ->
#         {:error, changeset}
#     end
#   end

#   @spec delete_goal(Goal.t()) :: {:ok, Goal.t()} | {:error, Ecto.Changeset.t()}
#   def delete_goal(goal) do
#     Repo.delete(goal)
#   end

#   # @spec convert_goals_for_session_recording(SessionRecording.t()) :: :ok
#   # def convert_goals_for_session_recording(%SessionRecording{} = session_recording) do
#   #   goals = get_goals(session_recording.project_id)
#   #   convert_goals(goals, [session_recording])
#   # end

#   # @spec convert_goal_for_session_recordings(PathGoal.t()) :: :ok
#   # def convert_goal_for_session_recordings(goal) do
#   #   session_recordings = SessionRecordings.get_session_recordings(goal.assoc_id)
#   #   convert_goals([goal], session_recordings)
#   # end

#   # @spec convert_goals([Goal.t()], [SessionRecording.t()]) :: :ok
#   # defp convert_goals(goals, session_recordings) do
#   #   session_recordings
#   #   |> Stream.chunk_every(500)
#   #   |> Stream.map(fn chunked_session_recordings ->
#   #     for goal <- goals,
#   #         session_recording <- chunked_session_recordings,
#   #         Goal.check_conversion(goal, session_recording) do
#   #       %{goal_id: goal.id, session_recording_id: session_recording.id}
#   #     end
#   #   end)
#   #   |> Stream.map(fn goal_session_recording_data ->
#   #     Repo.insert_all(ProjectGoalConversion, goal_session_recording_data, on_conflict: :nothing)
#   #   end)
#   #   |> Stream.run()

#   #   :ok
#   # end
# end
