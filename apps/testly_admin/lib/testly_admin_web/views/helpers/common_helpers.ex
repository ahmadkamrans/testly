defmodule TestlyAdminWeb.CommonHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  def active_link(text, opts) do
    # opts = opts ++ [class: opts[:class] <> " active"]

    link(text, opts)
  end
end
