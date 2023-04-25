defmodule Testly.SmartProxy.CssUrlReplacer.CssUrl do
  @doc """
  https://drafts.csswg.org/css-values-3/#urls

  <url> = url( <string> <url-modifier>* )

  It parses only http/https/relative links

  Bugs:
  1) It doesn't support <url-modifier>
  """

  @without_data ~s/(?!\s*data)/
  @single_quote_match ~s/'#{@without_data}(?:\\'|[^'])+'/
  @double_quote_match ~s/"#{@without_data}(?:\\"|[^"])+"/
  @without_quote_match ~s/#{@without_data}[^"',]+/
  @find_url_regex ~r/(url\s*\(\s*(#{@single_quote_match}|#{@double_quote_match}|#{@without_quote_match})\s*\))/iuU
  @find_import_regex ~r/@import\s*((#{@single_quote_match}|#{@double_quote_match}))/

  @spec find(String.t()) :: [{String.t(), String.t()}]
  def find(declaration) do
    matches =
      Regex.scan(@find_url_regex, declaration, capture: :all_but_first) ++
        Regex.scan(@find_import_regex, declaration, capture: :all_but_first)

    for [full_match, url] <- matches do
      {
        full_match,
        url
        |> String.replace_prefix("\"", "")
        |> String.replace_prefix("'", "")
        |> String.replace_suffix("'", "")
        |> String.replace_suffix("\"", "")
      }
    end
  end
end
