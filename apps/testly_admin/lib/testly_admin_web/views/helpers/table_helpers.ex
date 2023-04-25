defmodule TestlyAdminWeb.TableHelpers do
  @moduledoc """
  Helpers for rendering Torch-generated tables.
  """

  import Phoenix.HTML
  import Phoenix.HTML.Link

  @doc """
  Generates a sortable link for a table heading.

  Clicking on the link will trigger a sort on that field. Clicking again will
  reverse the sort.
  """
  def table_link(conn, %{direction: direction, field: current_field}, text, field) do
    if to_string(current_field) == to_string(field) do
      params = %{
        "order[field]" => field,
        "order[direction]" => reverse(direction)
      }

      link to: "?" <> querystring(conn, params), class: "active #{direction}" do
        raw(~s{#{text}<span class="caret"></span>})
      end
    else
      params = %{
        "order[field]" => field,
        "order[direction]" => direction
      }

      link to: "?" <> querystring(conn, params) do
        raw(~s{#{text}<span class="caret"></span>})
      end
    end
  end

  @doc """
  Prettifies and associated model for display.

  Displays the model's name or "None", rather than the model's ID.

  ## Example

      # If post.category_id was 1
      table_assoc_display_name(post, :category_id, [{"Articles", 1}])
      # => "Articles"

      # If post.category_id was nil
      table_assoc_display_name(post, :category_id, [{"Articles", 1}])
      # => "None"
  """
  def table_assoc_display_name(model, field, options) do
    case Enum.find(options, fn {_name, id} -> Map.get(model, field) == id end) do
      {name, _id} -> name
      _other -> "None"
    end
  end

  @doc false
  def querystring(conn, params) do
    original = URI.decode_query(conn.query_string)

    # opts = %{
    #   "pagination[page]" => opts[:page],
    #   "order[field]" => opts[:order_field] || conn.params["order_field"] || nil,
    #   "order[direction]" => opts[:order_direction] || conn.params["order_direction"] || nil
    # }

    original
    |> Map.merge(params)
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    |> URI.encode_query()
  end

  defp reverse(:desc), do: :asc
  defp reverse(:asc), do: :desc
  defp reverse(_), do: :desc
end
