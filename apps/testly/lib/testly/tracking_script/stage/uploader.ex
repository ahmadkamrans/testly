defmodule Testly.TrackingScript.Uploader do
  @moduledoc """
    The Uploader worker for UploaderSupervisor.
  """
  require Logger

  alias Testly.TrackingScript.Script

  def start_link({project_id, content}) do
    Task.start_link(fn ->
      case Script.store(content, project_id) do
        {:ok, _response} ->
          Logger.info("Tracking Script Upload Success (project_id : #{project_id})")

        {:error, error} ->
          Logger.error("Tracking Script Upload Error (project_id : #{project_id}, error: #{inspect(error)}")
      end
    end)
  end
end
