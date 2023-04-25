defmodule TestlyAPI.Schema.SplitTest.VariationConversionTypes do
  use Absinthe.Schema.Notation

  object :split_test_variation_conversion_rate_by_date do
    field :date, non_null(:date)
    field :conversion_rate, non_null(:float)
  end

  object :split_test_variation_conversion do
    field :conversion_rate, non_null(:float)
    field :conversions_count, non_null(:integer)
    field :visits_count, non_null(:integer)
    field :improvement_rate, :float
    field :is_winner, non_null(:boolean)
    field :revenue, non_null(:decimal)
    field :goal_id, non_null(:uuid4)
    field :variation_id, non_null(:uuid4)

    field :rates_by_date, non_null(list_of(non_null(:split_test_variation_conversion_rate_by_date)))
  end
end
