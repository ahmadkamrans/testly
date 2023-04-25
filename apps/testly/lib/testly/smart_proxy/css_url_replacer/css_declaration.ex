defmodule Testly.SmartProxy.CssUrlReplacer.CssDeclaration do
  @doc """
  # Declaraion in CSS
  Declarations are grouped in blocks, with each set
  of declarations being wrapped by an opening
  curly brace, ({) and a closing one (}).

  Each declaration contained inside a declaration block
  has to be separated by a semi-colon (;),
  otherwise the code won't work (or will at least give unexpected results.)
  The last declaration of a block doesn't need to be terminated
  by a semi-colon, though it is often considered good style
  to do so as it prevents forgetting to add it when extending
  the block with another declaration.

  Source: https://developer.mozilla.org/en-US/docs/Learn/CSS/Introduction_to_CSS/Syntax#CSS_declaration_blocks

  # How It Works
  It just keep finding `;` in string. It takes into account that `;` can be located
  in the string, like `content: "text;";`

  Finding till `;` is enough to find and replace any url()
  """

  require Integer

  @single_quote_string ~r/'(?:\\'|[^'])*(?<!\\)'/
  @double_quote_string ~r/"(?:\\"|[^"])*(?<!\\)"/

  @comment ~r|/\*[^*]*\*+([^/][^*]*\*+)*/|

  @spec find(String.t()) :: {String.t(), String.t()}
  def find(data) do
    parts = String.split(data, ";")

    if length(parts) === 1 do
      {"", data}
    else
      parts_last_index = length(parts) - 1

      parts =
        parts
        |> Enum.with_index()
        |> Enum.map(fn
          {part, ^parts_last_index} -> part
          {part, _} -> part <> ";"
        end)

      if String.ends_with?(data, ";") do
        find_declarations(parts)
      else
        {ready_declarations, part_of_next_declaration} = find_declarations(Enum.drop(parts, -1))

        {ready_declarations, part_of_next_declaration <> List.last(parts)}
      end
    end
  end

  @spec find_declarations([String.t()]) :: {String.t(), String.t()}
  @spec find_declarations([String.t()], String.t(), String.t()) :: {String.t(), String.t()}
  defp find_declarations(parts, temp_declarations \\ "", ready_declarations \\ "")

  defp find_declarations([part | parts], temp_declarations, ready_declarations) do
    new_temp_declarations = temp_declarations <> part

    if has_not_ended_string?(new_temp_declarations) || has_not_ended_comment?(new_temp_declarations) do
      find_declarations(parts, new_temp_declarations, ready_declarations)
    else
      find_declarations(parts, "", ready_declarations <> new_temp_declarations)
    end
  end

  defp find_declarations(_, part_of_next_declaration, ready_declarations) do
    {ready_declarations, part_of_next_declaration}
  end

  @spec has_not_ended_string?(String.t()) :: boolean()
  defp has_not_ended_string?(data_part) do
    data_part = Regex.replace(@comment, data_part, "")
    data_part = Regex.replace(@single_quote_string, data_part, "")
    data_part = Regex.replace(@double_quote_string, data_part, "")

    data_part =
      data_part
      |> String.replace("\\\"", "")
      |> String.replace("\\'", "")

    !(Integer.is_even(count_substring(data_part, "'")) && Integer.is_even(count_substring(data_part, "\"")))
  end

  defp has_not_ended_comment?(data_part) do
    data_part = Regex.replace(@comment, data_part, "")
    data_part = Regex.replace(@single_quote_string, data_part, "")
    data_part = Regex.replace(@double_quote_string, data_part, "")

    count_substring(data_part, "/*") !== count_substring(data_part, "*/")
  end

  @spec count_substring(String.t(), String.t()) :: pos_integer()
  defp count_substring(str, sub) do
    length(String.split(str, sub)) - 1
  end
end
