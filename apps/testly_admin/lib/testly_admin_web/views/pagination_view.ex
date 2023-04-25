defmodule TestlyAdminWeb.PaginationView do
  use TestlyAdminWeb, :view

  def prev_link(conn, current_page, _num_pages) do
    if current_page != 1 do
      link("«",
        to: "?" <> querystring(conn, %{"pagination[page]" => current_page - 1}),
        class: "page-link"
      )
    end
  end

  def next_link(conn, current_page, num_pages) do
    if current_page != num_pages do
      link("»",
        to: "?" <> querystring(conn, %{"pagination[page]" => current_page + 1}),
        class: "page-link"
      )
    end
  end

  defp start_page(current_page, distance) when current_page - distance < 1 do
    current_page - (distance + (current_page - distance - 1))
  end

  defp start_page(current_page, distance) do
    current_page - distance
  end

  defp end_page(current_page, 0, _distance) do
    current_page
  end

  defp end_page(current_page, total, distance)
       when current_page <= distance and distance * 2 <= total do
    distance * 2
  end

  defp end_page(current_page, total, distance) when current_page + distance >= total do
    total
  end

  defp end_page(current_page, _total, distance) do
    current_page + distance - 1
  end
end
