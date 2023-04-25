defmodule TestlyAPI.ErrorView do
  use TestlyAPI, :view

  def render("400.json", _assigns) do
    %{errors: %{detail: "Bad Request"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end
end
