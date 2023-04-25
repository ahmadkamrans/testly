defmodule Testly.SmartProxy.CssUrlReplacer.Replacer do
  alias Testly.SmartProxy.CssUrlReplacer.CssDeclaration
  alias Testly.SmartProxy.CssUrlReplacer.CssUrl

  @type to_proxy_url :: (String.t() -> String.t())

  @spec replace(String.t(), to_proxy_url(), is_end: boolean()) :: {String.t(), String.t()}
  def replace(data, to_proxy_url, is_end: is_end) do
    {ready_declarations, part_of_next_declaration} =
      if is_end do
        {data, ""}
      else
        CssDeclaration.find(data)
      end

    replaced_declarations =
      ready_declarations
      |> CssUrl.find()
      |> Enum.sort_by(fn {token, _} -> -String.length(token) end)
      |> Enum.map(fn {token, url} ->
        generated_proxy_url = to_proxy_url.(url)

        {token, String.replace(token, url, generated_proxy_url)}
      end)
      |> replace_urls(ready_declarations)

    {replaced_declarations, part_of_next_declaration}
  end

  @spec replace_urls([{String.t(), String.t()}], String.t()) :: Stirng.t()
  defp replace_urls([{url, proxy_url} | urls], declaration) do
    replace_urls(urls, String.replace(declaration, url, proxy_url))
  end

  defp replace_urls(_, declaration), do: declaration
end
