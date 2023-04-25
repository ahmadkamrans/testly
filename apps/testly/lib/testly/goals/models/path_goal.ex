defmodule Testly.Goals.PathGoal do
  use Testly.Goals.Goal

  alias Testly.Goals.PathStep
  alias Testly.SessionRecordings.{SessionRecording, Page}

  @type t :: %__MODULE__{
          id: Testly.Schema.pk(),
          assoc_id: Testly.Schema.pk(),
          name: String.t(),
          value: pos_integer(),
          path: [PathStep.t()],
          type: :path,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  goal_model do
    field :type, GoalTypeEnum, default: :path
    embeds_many :path, PathStep, on_replace: :delete
  end

  @spec goal_changeset(Changeset.t(), map) :: Changeset.t()
  def goal_changeset(changeset, _params) do
    changeset
    |> cast_embed(:path, required: true)
  end

  def cast_fields(changeset, _params) do
    changeset
    |> cast_embed(:path)
  end

  @spec check_conversion(PathGoal.t(), SessionRecording.t()) ::
          {:ok, happened_at :: DateTime.t()} | {:error, :no_conversion}
  def check_conversion(goal, session_recording) do
    match_path(session_recording.pages, goal.path, goal.path, :no_happened_at)
  end

  @spec match_path([Page.t()], [PathStep.t()], [PathStep.t()], DateTime.t() | :no_happened_at) ::
          {:ok, happened_at :: DateTime.t()} | {:error, :no_conversion}
  defp match_path([], [], _full_path, conversion_happened_at), do: {:ok, conversion_happened_at}
  defp match_path(_current_pages, [], _full_path, conversion_happened_at), do: {:ok, conversion_happened_at}
  defp match_path([], _current_path, _full_path, _conversion_happened_at), do: {:error, :no_conversion}

  defp match_path(
         [hd_page | tl_pages] = current_pages,
         [hd_step | tl_steps] = current_path,
         full_path,
         conversion_happened_at
       ) do
    if PathStep.match?(hd_step, hd_page.url) do
      match_path(tl_pages, tl_steps, full_path, hd_page.visited_at)
    else
      if length(current_path) == length(full_path) do
        match_path(tl_pages, full_path, full_path, conversion_happened_at)
      else
        match_path(current_pages, full_path, full_path, conversion_happened_at)
      end
    end
  end
end
