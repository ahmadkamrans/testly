defmodule Testly.Repo do
  alias Testly.Pagination

  @moduledoc false
  use Ecto.Repo,
    otp_app: :testly,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, opts}
  end

  def scrivener_paginate(pageable, %Pagination{page: page, per_page: per_page}) do
    Scrivener.paginate(
      pageable,
      Scrivener.Config.new(__MODULE__, [page_size: 10], [page: page, page_size: per_page])
    )
  end
end
