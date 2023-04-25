defmodule Testly.Heatmaps.ViewsCount do
  use Testly.Schema

  @primary_key false
  embedded_schema do
    field :total, :integer
    field :desktop, :integer
    field :mobile, :integer
    field :tablet, :integer
  end
end
