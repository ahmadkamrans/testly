defmodule Testly.SessionEvents.CssRuleDeletedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field :type, EventTypeEnum, default: :css_rule_deleted

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field :index, :integer
      field :node_id, :integer
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:index, :node_id])
    |> validate_required([:index, :node_id])
  end
end
