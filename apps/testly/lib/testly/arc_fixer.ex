defmodule Testly.ArcFixer do
  # Asset host doesn't work for local adapter
  # Waiting for https://github.com/stavro/arc/pull/65 to merge
  def fix_upload_url(nil), do: nil

  def fix_upload_url(url) do
    case URI.parse(url) do
      %URI{host: nil} ->
        "#{Application.fetch_env!(:arc, :asset_host)}#{url}"

      _ ->
        url
    end
  end
end
