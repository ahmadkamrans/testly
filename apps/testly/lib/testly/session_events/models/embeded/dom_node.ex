defmodule Testly.SessionEvents.DOMNode do
  use Testly.Schema

  alias __MODULE__
  alias Testly.SessionEvents.{ElementAttribute}

  # https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType
  @nodes %{
    element_node: 1,
    text_node: 3,
    cdata_section_node: 4,
    processing_instruction_node: 7,
    comment_node: 8,
    document_node: 9,
    document_type_node: 10,
    document_fragment_node: 11
  }

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :node_type, :integer
    field :tag_name, :string
    field :data, :string
    # present at text_node, comment_node and processing_instruction_node
    field :parent_tag, :string
    field :sheet_rules, {:array, :string}

    embeds_many :child_nodes, DOMNode, on_replace: :delete
    embeds_many :attributes, ElementAttribute, on_replace: :delete
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:id, :node_type, :tag_name, :data, :parent_tag, :sheet_rules])
    |> cast_embed(:attributes)
    |> cast_embed(:child_nodes)
    |> validate_required([:id, :node_type])
  end

  @spec node_type_name(number()) :: atom()
  def node_type_name(id) do
    case Enum.find(@nodes, fn {_name, node_id} -> node_id === id end) do
      nil -> raise "unknown node id #{inspect(id)}"
      {name, _id} -> name
    end
  end

  @spec node_type_id(atom()) :: number()
  def node_type_id(name) do
    case @nodes[name] do
      nil -> raise "unknown node name #{inspect(name)}"
      name -> name
    end
  end
end
