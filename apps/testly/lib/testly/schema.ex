defmodule Testly.Schema do
  @type pk :: Ecto.UUID.t()

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias Ecto.Changeset

      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID
      @timestamps_opts [type: :utc_datetime, inserted_at: :created_at, usec: true]
      @derive Jason.Encoder
    end
  end
end
