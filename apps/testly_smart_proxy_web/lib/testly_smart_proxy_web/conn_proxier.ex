defmodule TestlySmartProxyWeb.ConnProxier do
  alias Plug.Conn
  alias Testly.SmartProxy
  alias Testly.SmartProxy.{ProxyHeaders, ProxyChunk, ProxyEnd, ProxyError, ProxyTimeout}

  require Logger

  # Code adopted from https://github.com/tallarium/reverse_proxy_plug/blob/master/lib/reverse_proxy_plug.ex

  @headers_whitelist [
    "content-type",
    "date",
    "user-agent"
  ]

  @type option :: SmartProxy.start_proxy_opts() | {:proxier, atom()}

  @spec proxy(Plug.Conn.t(), [option]) :: Plug.Conn.t()
  def proxy(conn, opts) do
    proxier = opts[:proxier] || SmartProxy

    {pid, start_result} =
      proxier.start_proxy_stream(
        opts
        |> Keyword.delete(:proxier)
        |> Keyword.merge(stream_to: self())
      )

    conn =
      case start_result do
        :ok ->
          process_response(conn, opts)

        %ProxyError{message: message} ->
          Logger.error(fn -> "Proxy start failed, #{inspect(message)}, #{opts[:current_url]}" end)
          put_redirect(conn, opts)
      end

    proxier.stop_proxy_stream(pid)
    conn
  rescue
    e ->
      Logger.error(
        "Proxy exception raised for #{opts[:current_url]}, making usual redirect #{Exception.format(:error, e)}"
      )

      Honeybadger.notify(e, opts |> Enum.into(%{}))

      put_redirect(conn, opts)
  end

  @spec put_redirect(Plug.Conn.t(), [option]) :: Plug.Conn.t()
  defp put_redirect(conn, opts) do
    Phoenix.Controller.redirect(conn, external: opts[:current_url])
  end

  @spec process_response(Plug.Conn.t(), [option]) :: Plug.Conn.t()
  defp process_response(conn, opts) do
    receive do
      %ProxyEnd{} ->
        Logger.info(fn -> "Proxy stream finished for #{opts[:current_url]}" end)
        conn

      %ProxyHeaders{status_code: status_code, headers: headers} ->
        Logger.info(fn -> "Proxy got headers #{inspect(headers)} from #{opts[:current_url]}" end)

        headers
        |> Enum.map(fn {header, value} -> {String.downcase(header), value} end)
        |> Enum.filter(fn {header, _} -> Enum.member?(@headers_whitelist, header) end)
        |> Enum.concat([{"transfer-encoding", "chunked"}])
        |> Enum.reduce(conn, fn {header, value}, conn ->
          Conn.put_resp_header(conn, header, value)
        end)
        |> Conn.put_resp_header("cache-control", "private, max-age=3600")
        |> Conn.send_chunked(status_code)
        |> process_response(opts)

      %ProxyChunk{chunk: chunk} ->
        case Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            Logger.info(fn -> "Proxy chunk sent, #{opts[:current_url]}" end)
            process_response(conn, opts)

          {:error, :closed} ->
            Logger.error(fn -> "Proxy conn closed error, #{opts[:current_url]}" end)
            conn
        end

      %ProxyError{message: message} ->
        Logger.error(fn -> "Proxy error, #{message}, #{opts[:current_url]}" end)
        conn

      %ProxyTimeout{} ->
        Logger.info(fn -> "Proxy timeout, #{opts[:current_url]}" end)
        conn
    end
  end
end
