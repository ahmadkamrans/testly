defmodule Testly.SmartProxy.ProxierTest do
  use ExUnit.Case, async: true

  alias Testly.SmartProxy.Proxier
  alias Testly.SmartProxy.{ProxyError, ProxyChunk, ProxyEnd}

  @css_chunk_1 ".test {\n  background-color: green;\n}\n"
  @css_chunk_2 ".test2 {\n  background: url(../test.svg)\n}\n"

  @result_chunk_1 ".test {\n  background-color: green;"
  @result_chunk_2 "\n}\n.test2 {\n  background: url(../test.svg)\n}\n"

  test "transforms css" do
    {:ok, pid} =
      GenServer.start_link(Proxier,
        to_proxy_url: fn url -> url end,
        url: "http://test.com/a/b.css?test=true",
        stream_to: self()
      )

    send(pid, %HTTPotion.AsyncChunk{chunk: @css_chunk_1})
    assert_receive %ProxyChunk{chunk: @result_chunk_1}

    send(pid, %HTTPotion.AsyncChunk{chunk: @css_chunk_2})
    refute_receive _

    send(pid, %HTTPotion.AsyncEnd{})
    assert_receive %ProxyChunk{chunk: @result_chunk_2}
    assert_receive %ProxyEnd{}
  end

  test "keeps other files" do
    {:ok, pid} =
      GenServer.start_link(Proxier, to_proxy_url: fn url -> url end, url: "http://test.com/a/b.png", stream_to: self())

    send(pid, %HTTPotion.AsyncChunk{chunk: @css_chunk_1})
    assert_receive %ProxyChunk{chunk: @css_chunk_1}

    send(pid, %HTTPotion.AsyncChunk{chunk: @css_chunk_2})
    assert_receive %ProxyChunk{chunk: @css_chunk_2}

    send(pid, %HTTPotion.AsyncEnd{})
    refute_receive %ProxyChunk{}
    assert_receive %ProxyEnd{}
  end

  test "sends ProxyError on conn error" do
    {:ok, pid} =
      GenServer.start_link(Proxier, to_proxy_url: fn url -> url end, url: "http://test.com/a/b.png", stream_to: self())

    send(pid, {self(), {:error, {:conn_failed, {:error, :timeout}}}})

    assert_receive %ProxyError{message: :conn_failed}

    Process.sleep(100)

    assert Process.alive?(pid) === false
  end

  test "sends ProxyError on connection_closing error" do
    {:ok, pid} =
      GenServer.start_link(Proxier, to_proxy_url: fn url -> url end, url: "http://test.com/a/b.png", stream_to: self())

    send(pid, {self(), {:error, :connection_closing}})

    assert_receive %ProxyError{message: :connection_closing}

    Process.sleep(100)

    assert Process.alive?(pid) === false
  end
end
