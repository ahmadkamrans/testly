defmodule Testly.SessionEvents.CssRuleInsertedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :css_rule_inserted

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :rule, :string
      field :index, :integer
      field :node_id, :integer
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:rule, :index, :node_id])
    |> validate_required([:rule, :index, :node_id])
  end
end
