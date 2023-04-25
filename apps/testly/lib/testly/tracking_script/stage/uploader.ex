defmodule Testly.TrackingScript.Uploader do
  @moduledoc """
    The Uploader worker for UploaderSupervisor.
  """
  require Logger

  alias Testly.TrackingScript.Script
  alias Testly.CloudFlare

  def start_link({project_id, content}) do
    Task.start_link(fn ->
      with {:ok, _reponse} <- Script.store(content, project_id),
           :ok <- CloudFlare.reset_cdn_cache() do
        Logger.info("Tracking Script Upload Success (project_id : #{project_id})")
      else
        e ->
          Logger.error("Tracking Script Upload Error (project_id : #{project_id}, error: #{inspect(e)}")
      end
    end)
  end
end
