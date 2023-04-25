# defmodule Testly.SessionRecordings.SessionRecordingQuery do
#   import Ecto.Query, only: [from: 2]

#   alias Testly.SessionRecordings.SessionRecording

#   def from_session_recording do
#     from(p in SessionRecording, as: :session_recording)
#   end

#   def join_snapshot(query) do
#     from([page: p] in query, join: s in assoc(p, :snapshots), as: :snapshot)
#   end

#   def join_view(query) do
#     from([snapshot: s] in query, join: v in assoc(s, :views), as: :view)
#   end

#   def preload_assocs(query) do
#     from(p in query, preload: [snapshots: [:views]])
#   end

#   def where_project_id(query, value) do
#     from([page: p] in query, where: p.project_id == ^value)
#   end

#   def where_url_contains(query, value) do
#     from([page: p] in query, where: ilike(p.url, ^"%#{value}%"))
#   end
# end
