defmodule Testly.SplitTests.ConversionReportQuery do
  import Ecto.Query

  alias Testly.SplitTests.{ConversionReport}

  def from_schema() do
    from(c_r in ConversionReport, as: :conversion_report)
  end

  def where_variation_id_in(query, ids) do
    where(query, [conversion_report: c_r], c_r.variation_id in ^ids)
  end

  def where_goal_id(query, id) do
    where(query, [conversion_report: c_r], c_r.goal_id == ^id)
  end
end
