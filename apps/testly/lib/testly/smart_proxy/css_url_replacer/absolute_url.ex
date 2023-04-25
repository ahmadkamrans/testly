defmodule Testly.SmartProxy.CssUrlReplacer.AbsoluteUrl do
  @spec generate(String.t(), String.t()) :: String.t()
  def generate(current_url, relative_url) do
    parsed_current_url = URI.parse(current_url)
    parsed_relative_url = URI.parse(relative_url)

    %URI{
      authority: parsed_relative_url.authority || parsed_current_url.authority,
      host: parsed_relative_url.host || parsed_current_url.host,
      port: parsed_relative_url.port || parsed_current_url.port,
      scheme: parsed_relative_url.scheme || parsed_current_url.scheme,
      userinfo: parsed_relative_url.userinfo || parsed_current_url.userinfo,
      fragment: parsed_relative_url.fragment,
      query: parsed_relative_url.query,
      path: URI.merge(parsed_current_url, parsed_relative_url.path || "").path
    }
    |> to_string()
  end
end
