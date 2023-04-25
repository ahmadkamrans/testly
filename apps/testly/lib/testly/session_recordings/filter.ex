defmodule Testly.SessionRecordings.Filter do
  @moduledoc """
  Example of predicates https://github.com/activerecord-hackery/ransack#search-matchers
  """

  import Ecto.Query, only: [from: 2]

  alias __MODULE__
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.FilterApplier

  defstruct [
    :created_at_gteq,
    :created_at_lteq,
    :duration_gteq,
    :duration_lteq,
    :location_country_iso_code_in,
    :device_type_in,
    :referrer_source_in,
    :converted_project_goal_ids_in,
    :converted_split_test_goal_ids_in,
    :split_test_id_eq
  ]

  @type t() :: %__MODULE__{}

  def filter(%Filter{} = filter) do
    query =
      from(
        s_r in SessionRecording,
        as: :session_recordings
      )

    # TODO: move to https://hexdocs.pm/ecto/Ecto.Query.html#has_named_binding?/2
    # to avoid multiple joins with the same table

    FilterApplier.apply(query, filter, &query_filter/3)
  end

  defp query_filter(:created_at_gteq, q, value) do
    from([session_recordings: s_r] in q, where: s_r.created_at >= ^value)
  end

  defp query_filter(:created_at_lteq, q, value) do
    from([session_recordings: s_r] in q, where: s_r.created_at <= ^value)
  end

  defp query_filter(:duration_gteq, q, value) do
    from([session_recordings: s_r] in q, where: s_r.duration >= ^value)
  end

  defp query_filter(:duration_lteq, q, value) do
    from([session_recordings: s_r] in q, where: s_r.duration <= ^value)
  end

  defp query_filter(:referrer_source_in, q, values) do
    from([session_recordings: s_r] in q, where: s_r.referrer_source in ^values)
  end

  defp query_filter(:location_country_iso_code_in, q, values) do
    q =
      from([session_recordings: s_r] in q,
        join: l in assoc(s_r, :location),
        as: :location
      )

    from([location: l] in q, where: l.country_iso_code in ^values)
  end

  defp query_filter(:device_type_in, q, values) do
    q =
      from([session_recordings: s_r] in q,
        join: d in assoc(s_r, :device),
        as: :device
      )

    from([device: d] in q, where: d.type in ^values)
  end

  defp query_filter(:converted_project_goal_ids_in, q, values) do
    q =
      from([session_recordings: s_r] in q,
        left_join: p_g in assoc(s_r, :converted_project_goals),
        as: :converted_project_goals
      )

    from([converted_project_goals: c_p_g] in q, where: c_p_g.id in ^values)
  end

  defp query_filter(:converted_split_test_goal_ids_in, q, values) do
    q =
      from([session_recordings: s_r] in q,
        left_join: s_g in assoc(s_r, :split_test_goals),
        as: :split_test_goals
      )

    from([split_test_goals: s_t_g] in q, where: s_t_g.id in ^values)
  end

  defp query_filter(:split_test_id_eq, q, value) do
    q =
      from([session_recordings: s_r] in q,
        left_join: s_t_v in assoc(s_r, :split_test_variations),
        as: :split_test_variations
      )

    from([split_test_variations: s_t_v] in q, where: s_t_v.split_test_id == ^value)
  end
end
