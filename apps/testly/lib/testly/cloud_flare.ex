defmodule Testly.CloudFlare do
  require Logger

  # TODO: make by tag purge
  @spec reset_cdn_cache() :: :ok | {:error, any()}
  def reset_cdn_cache do
    cdn_config = Application.get_env(:testly, Testly.CloudFlare)

    zone_identifier = Keyword.fetch!(cdn_config, :zone_identifier)
    auth_token = Keyword.fetch!(cdn_config, :auth_token)

    request_response =
      HTTPotion.post("https://api.cloudflare.com/client/v4/zones/#{zone_identifier}/purge_cache",
        headers: [
          {"Authorization", "Bearer #{auth_token}"},
          {"Content-Type", "application/json"}
        ],
        body: '{"purge_everything":true}'
      )

    with %HTTPotion.Response{body: body} <- request_response,
         {:ok, decoded_body} <- Jason.decode(body),
         %{"success" => true} <- decoded_body do
      Logger.info("CDN cache is purged!")

      :ok
    else
      e ->
        {:error, e}
    end
  end
end
