defmodule TestlyHome.ScriptRedirector do
  require Logger
  import Plug.Conn

  @external_urls Application.get_env(:testly_home, :external_urls)
  @testly_old_site_url Keyword.fetch!(@external_urls, :testly_old_site)

  @moduledoc """
  This module is used to redirect all old testly requests of the script to
  old the old testly site.
  """

  def init(options), do: options

  # Url example - http://testly.com/tracking/1023/script.js?on=http://localhost:4000/
  def call(conn, _opts) do
    if String.starts_with?(conn.request_path, "/tracking/") do
      url = "#{@testly_old_site_url}#{conn.request_path}?#{conn.query_string}"
      Logger.debug(fn -> "Redirecting to #{url}, we support old scripts from old.testly.com" end)

      conn
      |> Phoenix.Controller.redirect(external: url)
      |> halt()
    else
      conn
    end
  end
end
