defmodule TestlyAPI.Schema.Types do
  use Absinthe.Schema.Notation

  # TODO: Put all global enums here

  enum(:order_direction,
    values: [
      :asc,
      :desc
    ]
  )

  enum(:page_matcher_match_type,
    values: [
      :matches_exactly,
      :contains,
      :begins_with,
      :ends_with
    ]
  )

  input_object :pagination do
    field :page, :integer, default_value: 1
    field :per_page, :integer, default_value: 10
  end

  input_object :cursor_pagination do
    field :limit, :integer, default_value: 30
    field :before, :string
    field :after, :string
  end

  input_object :page_matcher_params do
    field :url, non_null(:string)
    field :match_type, non_null(:page_matcher_match_type)
  end

  object :page_matcher do
    field :url, non_null(:string)
    field :match_type, non_null(:page_matcher_match_type)
  end

  object :cursor_page_info do
    field :before, :string
    field :after, :string

    field :has_next_page, non_null(:boolean) do
      resolve(fn %{after: after_cursor}, _args, _resolution ->
        {:ok, after_cursor !== nil}
      end)
    end

    field :has_previous_page, non_null(:boolean) do
      resolve(fn %{before: before_cursor}, _args, _resolution ->
        {:ok, before_cursor !== nil}
      end)
    end
  end

  object :offset_page_info do
    field :total_count, non_null(:integer)
  end

  # enum(:referrer_source,
  #   values: [
  #     :social,
  #     :search,
  #     :paid,
  #     :email,
  #     :direct,
  #     :unknown
  #   ]
  # )
end
