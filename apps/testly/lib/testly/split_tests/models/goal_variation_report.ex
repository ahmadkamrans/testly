defmodule Testly.SplitTests.GoalVariationReport do
  use Testly.Schema

  alias Testly.Goals.Goal
  alias Testly.SplitTests.{Variation, GoalVariationReport}

  @type t :: %__MODULE__{}
  schema "split_test_goal_variation_reports" do
    field(:goal_id, Ecto.UUID)
    field(:variation_id, Ecto.UUID)
    field(:conversions_count, :integer)
    field(:visits_count, :integer)
    field(:conversion_rate, :float)
    field(:revenue, :decimal)
    field(:improvement_rate, :float)
    field(:control, :boolean)

    field(:is_winner, :boolean, virtual: true)

    timestamps()

    embeds_many :rates_by_date, RateByDateReport, primary_key: false do
      field(:date, :date)
      field(:conversion_rate, :float)
    end
  end

  @spec generate_report(Goal.t(), Variation.t()) :: GoalVariationReport.t()
  def generate_report(goal, variation) do
    conversions = filter_conversions_by_visits(goal.conversions, variation.visits)

    visits_count = Enum.count(variation.visits)
    conversions_count = Enum.count(conversions)
    revenue = Decimal.mult(Decimal.new(conversions_count), goal.value)
    conversion_rate = calc_conversion_rate(conversions_count, visits_count)

    %__MODULE__{
      goal_id: goal.id,
      variation_id: variation.id,
      conversion_rate: conversion_rate,
      conversions_count: conversions_count,
      visits_count: visits_count,
      revenue: revenue,
      control: variation.control
    }
  end

  def put_rates_by_date_reports(%__MODULE__{} = report, goal, variation, from_date, to_date) do
    conversions = filter_conversions_by_visits(goal.conversions, variation.visits)

    visits_by_date =
      variation.visits
      |> Enum.group_by(&DateTime.to_date(&1.visited_at))
      |> Enum.into(%{})

    rates_by_date =
      Date.range(from_date, to_date)
      |> Enum.map(&generate_rate_by_date_report(&1, visits_by_date[&1], conversions))

    %__MODULE__{report | rates_by_date: rates_by_date}
  end

  defp generate_rate_by_date_report(date, nil, _conversions) do
    %__MODULE__.RateByDateReport{
      date: date,
      conversion_rate: 0.0
    }
  end

  defp generate_rate_by_date_report(date, visits, conversions) do
    date_conversions = filter_conversions_by_visits(conversions, visits)

    %__MODULE__.RateByDateReport{
      date: date,
      conversion_rate: calc_conversion_rate(Enum.count(date_conversions), Enum.count(visits))
    }
  end

  defp filter_conversions_by_visits(conversions, visits) do
    visit_ids = Enum.map(visits, & &1.id)
    Enum.filter(conversions, &(&1.assoc_id in visit_ids))
  end

  defp calc_conversion_rate(conversions_count, visits_count) do
    if conversions_count > 0 do
      conversions_count / visits_count * 100
    else
      0.0
    end
  end

  def put_is_winner(reports, true = _is_finished) do
    is_any_winner = Enum.count(Enum.group_by(reports, & &1.conversion_rate)) > 1
    winner = Enum.max_by(reports, & &1.conversion_rate)

    for report <- reports do
      %GoalVariationReport{report | is_winner: is_any_winner && report == winner}
    end
  end

  def put_is_winner(reports, false = _is_finished) do
    for report <- reports do
      %GoalVariationReport{report | is_winner: false}
    end
  end

  def put_improvement_rate(reports) do
    control_report = Enum.find(reports, & &1.control)

    for report <- reports do
      %GoalVariationReport{
        report
        | improvement_rate: calc_improvement_rate(report, control_report)
      }
    end
  end

  defp calc_improvement_rate(%GoalVariationReport{control: true}, _control_report), do: nil

  defp calc_improvement_rate(report, %GoalVariationReport{conversion_rate: 0} = report),
    do: calc_improvement_rate(report, %GoalVariationReport{report | conversion_rate: 0.0})

  defp calc_improvement_rate(_report, %GoalVariationReport{conversion_rate: 0.0}),
    do: nil

  defp calc_improvement_rate(report, control_report) do
    (report.conversion_rate / control_report.conversion_rate - 1) * 100
  end
end
