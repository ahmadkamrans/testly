defmodule Testly.SessionEvents.PageVisitedEvent do
  use Testly.SessionEvents.Event

  event_model do
    field(:type, EventTypeEnum, default: :page_visited)

    embeds_one :data, Data, on_replace: :delete, primary_key: false do
      @derive Jason.Encoder
      field(:origin, :string)
      field(:doc_type, :string)
      field(:url, :string)
      field(:title, :string)
      embeds_one(:dom_snapshot, Testly.SessionEvents.DOMNode)
    end
  end

  @spec data_changeset(%__MODULE__.Data{}, map) :: Ecto.Changeset.t()
  def data_changeset(schema, params) do
    schema
    |> cast(params, [:origin, :doc_type, :url, :title])
    |> validate_required([:origin, :doc_type, :url, :title])
    |> cast_embed(:dom_snapshot, required: true)
  end
end
