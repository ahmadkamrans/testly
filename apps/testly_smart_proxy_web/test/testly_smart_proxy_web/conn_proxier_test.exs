defmodule TestlySmartProxyWeb.ConnProxierTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Testly.SmartProxy.{ProxyHeaders, ProxyChunk, ProxyEnd, ProxyError}
  alias TestlySmartProxyWeb.ConnProxier
  alias Testly.SmartProxyMock

  @response_headers_to_remove [
    {"connection", "keep-alive"},
    {"keep-alive", "timeout=5, max=1000"},
    {"upgrade", "h2c"},
    {"proxy-authenticate", "Basic"},
    {"proxy-authorization", "Basic abcd"},
    {"te", "compress"},
    {"trailer", "Expires"},
    {"Set-Cookie", "test"},
    {"content-length", "1281"},
    {"host", "123"},
    {"content-type", "test"},
    {"date", "Tue, 15 Nov 1994 08:12:31 GMT"}
  ]

  @headers_to_keep [
    {"content-type", "test"},
    {"date", "Tue, 15 Nov 1994 08:12:31 GMT"}
  ]

  @added_headers [
    {"transfer-encoding", "chunked"}
  ]

  @cache_headers [
    {"cache-control", "private, max-age=3600"}
  ]

  defp put_response(status, headers, body \\ "Success", no_chunks \\ 2) do
    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    send(self(), %ProxyHeaders{status_code: status, headers: headers})

    body
    |> String.codepoints()
    |> Enum.chunk_every(Float.ceil(String.length(body) / no_chunks) |> trunc())
    |> Enum.map(&Enum.join/1)
    |> Enum.each(fn chunk ->
      send(self(), %ProxyChunk{chunk: chunk})
    end)

    send(self(), %ProxyEnd{})

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, no_chunks + 2}

    :ok
  end

  test "proxy response" do
    put_response(200, @response_headers_to_remove ++ @headers_to_keep)

    SmartProxyMock
    |> expect(:start_proxy_stream, fn _ -> {123, :ok} end)
    |> expect(:stop_proxy_stream, fn 123 -> :ok end)

    conn = ConnProxier.proxy(conn(:get, "/"), proxier: SmartProxyMock)

    assert conn.resp_headers == @cache_headers ++ @headers_to_keep ++ @added_headers
    assert conn.resp_body == "Success"
  end

  test "when failed to establish connection" do
    SmartProxyMock
    |> expect(:start_proxy_stream, fn _ -> {123, %ProxyError{message: "failed"}} end)
    |> expect(:stop_proxy_stream, fn 123 -> :ok end)

    conn = ConnProxier.proxy(conn(:get, "/"), proxier: SmartProxyMock, current_url: "http://google.com")

    assert {"location", "http://google.com"} in conn.resp_headers
  end
end
