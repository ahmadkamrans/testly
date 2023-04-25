defmodule Testly.SessionEvents.Event do
  use Testly.Schema

  alias Testly.SessionEvents.{EventSchema}

  @type t ::
          MouseMovedEvent.t()
          | MouseClickedEvent.t()

  @modules %{
    "mouse_moved" => Testly.SessionEvents.MouseMovedEvent,
    "dom_mutated" => Testly.SessionEvents.DOMMutatedEvent,
    "mouse_clicked" => Testly.SessionEvents.MouseClickedEvent,
    "page_visited" => Testly.SessionEvents.PageVisitedEvent,
    "scrolled" => Testly.SessionEvents.ScrolledEvent,
    "window_resized" => Testly.SessionEvents.WindowResizedEvent,
    "css_rule_inserted" => Testly.SessionEvents.CssRuleInsertedEvent,
    "css_rule_deleted" => Testly.SessionEvents.CssRuleDeletedEvent,
  }

  def to_event(%EventSchema{type: type} = event_schema) do
    type_to_module(type).to_event(event_schema)
  end

  def to_entry(event) do
    Map.take(event, [:id, :session_recording_id, :page_id, :happened_at, :type, :data, :is_processed])
  end

  def process_event(event, page) do
    %{event | is_processed: true, page_id: page.id}
  end

  @spec create_changesets(Testly.Schema.pk(), map()) :: Changeset.t()
  def create_changeset(session_recording_id, params) do
    module = type_to_module(params["type"])

    module
    |> struct(session_recording_id: session_recording_id)
    |> module.create_changeset(params)
  end

  @spec create_changesets(Testly.Schema.pk(), [map()]) :: {:ok, [Changeset.t()]} | {:error, [Changeset.t()]}
  def create_changesets(session_recording_id, params) do
    changesets = Enum.map(params, &create_changeset(session_recording_id, &1))
    invalid_changesets = Enum.filter(changesets, &(&1.valid? == false))

    if Enum.empty?(invalid_changesets) do
      {:ok, changesets}
    else
      {:error, invalid_changesets}
    end
  end

  defp type_to_module(type) do
    case @modules[to_string(type)] do
      nil -> raise "Unknown type #{inspect(type)}"
      module -> module
    end
  end

  defmacro __using__(_) do
    quote do
      use Testly.Schema
      import Testly.SessionEvents.Event, only: [event_model: 1]
    end
  end

  defmacro event_model(do: block) do
    quote do
      alias Testly.SessionEvents.EventTypeEnum
      alias Testly.SessionEvents.EventSchema

      @primary_key false
      embedded_schema do
        field :id, Ecto.UUID
        field :session_recording_id, Ecto.UUID
        field :page_id, Ecto.UUID
        field :is_processed, :boolean, default: false
        field :happened_at, :utc_datetime_usec
        field :timestamp, :integer, virtual: true

        unquote(block)
      end

      @spec create_changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
      def create_changeset(schema, params) do
        schema
        |> cast(params, [:timestamp])
        |> validate_required([:timestamp])
        |> cast_timestamp()
        |> cast_embed(:data, with: &data_changeset/2)
        |> put_change(:id, Ecto.UUID.generate())
      end

      def to_event(%EventSchema{} = event_schema) do
        cast(struct(__MODULE__), Map.from_struct(event_schema), [:id, :page_id, :session_recording_id, :happened_at])
        |> cast_embed(:data, with: &data_changeset/2)
        |> Ecto.Changeset.apply_changes()
      end

      defp cast_timestamp(%Ecto.Changeset{valid?: true} = changeset) do
        changeset
        |> Ecto.Changeset.get_change(:timestamp)
        |> Kernel.*(1000)
        |> DateTime.from_unix(:microsecond)
        |> case do
          {:ok, datetime} -> put_change(changeset, :happened_at, datetime)
          {:error, reason} -> add_error(changeset, :timestamp, reason)
        end
      end

      defp cast_timestamp(ch), do: ch
    end
  end
end
