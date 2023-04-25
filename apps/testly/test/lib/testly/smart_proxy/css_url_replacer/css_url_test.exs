defmodule Testly.SmartProxy.CssUrlTest do
  use ExUnit.Case, async: true

  alias Testly.SmartProxy.CssUrlReplacer.CssUrl

  test "works with multiline urls" do
    assert [
             "url(https://google.com)",
             "url(\"https://test.com\")",
             "url(\'https://test.com\')",
             "url(\'https://goo.com\')"
           ]
           |> Enum.join(", \n")
           |> CssUrl.find() == [
             {"url(https://google.com)", "https://google.com"},
             {"url(\"https://test.com\")", "https://test.com"},
             {"url(\'https://test.com\')", "https://test.com"},
             {"url(\'https://goo.com\')", "https://goo.com"}
           ]
  end

  test "works with sequence of the same quotes" do
    assert CssUrl.find(~s|url("https://test.com") url("https://goo.com")|) == [
             {"url(\"https://test.com\")", "https://test.com"},
             {"url(\"https://goo.com\")", "https://goo.com"}
           ]
  end

  test "works with single quote" do
    assert CssUrl.find("test: url('https://test.com')") == [{"url('https://test.com')", "https://test.com"}]
  end

  test "works with double quote" do
    assert CssUrl.find("url(\"https://test.com\")") == [{"url(\"https://test.com\")", "https://test.com"}]
  end

  test "works with without quote" do
    assert CssUrl.find("url(https://google.com)") == [{"url(https://google.com)", "https://google.com"}]
  end

  test "works with parentheses inside quotes" do
    assert CssUrl.find("url('https://google.com/test (1).jpeg')") == [
      {"url('https://google.com/test (1).jpeg')", "https://google.com/test (1).jpeg"}
    ]
  end

  test "works with new line" do
    assert CssUrl.find("url(https://google.com/test \n .jpeg)") == [
      {"url(https://google.com/test \n .jpeg)", "https://google.com/test \n .jpeg"}
    ]
  end

  test "works with escaped single/double quotes in URL" do
    assert CssUrl.find("url('https://google.com/test\\\'.jpeg')") == [
      {"url('https://google.com/test\\\'.jpeg')", "https://google.com/test\\'.jpeg"}
    ]
    assert CssUrl.find("url(\"https://google.com/test\\\".jpeg\")") == [
      {"url(\"https://google.com/test\\\".jpeg\")", "https://google.com/test\\\".jpeg"}
    ]
  end

  test "doesn't works with data:" do
    assert CssUrl.find("url('  data:google.com/test\\\'.jpeg')") == []
    assert CssUrl.find("url( data:google.com)") == []
    assert CssUrl.find("url(\"   data:google.com/test\\\'.jpeg\")") == []
    assert CssUrl.find("url('data:google.com/test\\\'.jpeg')") == []
  end

  test "works with relative path" do
    assert CssUrl.find("url(test.css)") == [{"url(test.css)", "test.css"}]
    assert CssUrl.find("url(./test.css)") == [{"url(./test.css)", "./test.css"}]
    assert CssUrl.find("url(\"./test.css\")") == [{"url(\"./test.css\")", "./test.css"}]
    assert CssUrl.find("url(\'./test.css\')") == [{"url(\'./test.css\')", "./test.css"}]
  end

  test "works with // paths" do
    assert CssUrl.find("url(//test.css)") == [{"url(//test.css)", "//test.css"}]
    assert CssUrl.find("url(//test.css)") == [{"url(//test.css)", "//test.css"}]
    assert CssUrl.find("url(\"//test.css\")") == [{"url(\"//test.css\")", "//test.css"}]
    assert CssUrl.find("url(\'//test.css\')") == [{"url(\'//test.css\')", "//test.css"}]
  end

  test "works with @import" do
    assert CssUrl.find("@import url('https://test.com')") == [{"url('https://test.com')", "https://test.com"}]
    assert CssUrl.find("\n  @import   'https://\\'test.com'") == [{"'https://\\'test.com'", "https://\\'test.com"}]
  end

  test "(bug) doesn't support url-modifier" do
    assert CssUrl.find("url('https://test.com' prefetch)") == []
  end
end
