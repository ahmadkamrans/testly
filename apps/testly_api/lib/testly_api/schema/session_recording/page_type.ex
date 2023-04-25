defmodule TestlyAPI.Schema.SessionRecording.PageType do
  use Absinthe.Schema.Notation

  object :session_recording_page do
    field :id, non_null(:uuid4)

    field :title, non_null(:string)
    field :url, non_null(:string)
    field :duration, non_null(:integer)
    field :visited_at, non_null(:datetime)
  end
end
