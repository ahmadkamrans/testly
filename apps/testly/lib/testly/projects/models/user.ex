defmodule Testly.Projects.User do
  use Testly.Schema

  alias Testly.Projects.Project

  @type t :: %__MODULE__{
          full_name: String.t()
        }

  schema "users" do
    has_many :projects, Project
    field :full_name, :string

    timestamps()
  end
end
