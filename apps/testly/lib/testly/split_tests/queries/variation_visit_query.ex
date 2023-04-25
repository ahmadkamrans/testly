defmodule Testly.SplitTests.VariationVisitQuery do
  import Ecto.Query

  def from_variation_visit do
    from(v_v in VariationVisit, as: :variation_visit)
  end

  def left_join_variation(query) do
    join(query, :left, [variation_visit: v_v], v in assoc(v_v, :variation), as: :variation)
  end
end
