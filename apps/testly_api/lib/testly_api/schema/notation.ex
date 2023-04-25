defmodule TestlyAPI.Schema.Notation do
  defmacro __using__(_opts) do
    quote do
      use Absinthe.Schema.Notation
      import(Kronky.Payload)
      import Absinthe.Resolution.Helpers
    end
  end

  # TODO: "connection" macro
  # defmacro connection(connection_name, do: block) do
  #   quote location: :keep do
  #     object unquote(connection_name) do
  #       field :nodes, non_null(:boolean)
  #       field :total_count, unquote(result_object_name)
  #       unquote(block)
  #     end
  #   end
  # end
end
