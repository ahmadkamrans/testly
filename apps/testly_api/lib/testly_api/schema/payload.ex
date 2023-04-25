defmodule TestlyAPI.Schema.Payload do
  # Is taken from https://github.com/Ethelo/kronky/blob/master/lib/kronky/payload.ex#L118
  # Changes - `non_null` is added to all fields. It ease work with generated typesript types
  defmacro payload_object(payload_name, result_object_name) do
    quote location: :keep do
      object unquote(payload_name) do
        field :successful, non_null(:boolean), description: "Indicates if the mutation completed successfully or not. "

        # Is changed
        field :messages, non_null(list_of(non_null(:validation_message))),
          description: "A list of failed validations. May be blank or null if mutation succeeded."

        field :result, unquote(result_object_name),
          description: "The object created/updated/deleted by the mutation. May be null if mutation failed."
      end
    end
  end
end
