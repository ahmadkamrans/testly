defmodule Testly.TrackingScript.SourceDownloader do
  require Logger

  def download do
    source_script_url = Application.get_env(:testly, Testly.TrackingScript)[:source_script_url]

    case HTTPotion.get(source_script_url) do
      %HTTPotion.Response{status_code: 200, body: body} ->
        {:ok, body}

      resp ->
        Logger.error("Failed to get script #{inspect(resp)}")

        :error
    end
  end
end
