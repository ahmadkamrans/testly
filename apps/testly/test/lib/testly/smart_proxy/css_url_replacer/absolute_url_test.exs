defmodule Testly.SmartProxy.AbsoluteUrlTest do
  use ExUnit.Case, async: true

  alias Testly.SmartProxy.CssUrlReplacer.AbsoluteUrl

  test "when relative path" do
    assert AbsoluteUrl.generate("http://test.com/a/c/b.txt?test=true", "../t.css") == "http://test.com/a/t.css"
    assert AbsoluteUrl.generate("http://test.com/a/b.txt#test", "./t.css") == "http://test.com/a/t.css"
    assert AbsoluteUrl.generate("http://test.com/a/b.txt", "/t.css") == "http://test.com/t.css"
  end

  test "when absolute path" do
    assert AbsoluteUrl.generate("http://test.com/a/b.txt", "http://test.com/a/c.txt") == "http://test.com/a/c.txt"
  end

  test "when path srarts with //" do
    assert AbsoluteUrl.generate("http://test.com/a/b.txt", "//test.com/a/c.txt") == "http://test.com/a/c.txt"
    assert AbsoluteUrl.generate("https://test.com/a/b.txt", "//test.com/a/c.txt") == "https://test.com/a/c.txt"
  end
end
