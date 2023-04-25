defmodule TestlyRecorderAPI.ErrorView do
  use TestlyRecorderAPI, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("400.json", _assigns) do
    %{errors: %{detail: "Bad Request"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end
end
