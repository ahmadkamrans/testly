defmodule Testly.SessionRecordings.SplitTest.Goal do
  use Testly.Schema

  alias __MODULE__

  @type t :: %Goal{
          id: Testly.Schema.pk(),
          name: String.t()
        }

  schema "split_test_goals" do
    field :name, :string
    field :split_test_id, Ecto.UUID
  end
end
