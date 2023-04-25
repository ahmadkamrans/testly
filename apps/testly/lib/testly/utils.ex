defmodule Testly.Utils do
  def to_map(list) when is_list(list) do
    for value <- list, do: to_map(value)
  end

  def to_map(%_{} = struct) do
    for {k, v} <- Map.from_struct(struct), into: %{}, do: {k, to_map(v)}
  end

  def to_map(value), do: value

  def stringify_keys(%{} = map) do
    map
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), stringify_keys(v)} end)
  end

  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end
end
