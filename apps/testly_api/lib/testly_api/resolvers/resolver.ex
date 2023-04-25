defmodule TestlyAPI.Resolver do
  defmacro __using__(_opts) do
    quote do
      import TestlyAPI.Resolver
      import Appsignal.Instrumentation.Helpers, only: [instrument: 3]
    end
  end

  @spec map_error_to_ok({:error, any()} | {:ok, any()}) :: {:ok, any()}
  def map_error_to_ok({:error, data}), do: {:ok, data}
  def map_error_to_ok({:ok, data}), do: {:ok, data}
end
