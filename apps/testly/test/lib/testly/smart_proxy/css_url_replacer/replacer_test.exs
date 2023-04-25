defmodule Testly.SmartProxy.CssUrlReplacer.ReplacerTest do
  use ExUnit.Case, async: true

  alias Testly.SmartProxy.CssUrlReplacer.Replacer

  def proxy_url(url) do
    "http://proxy.com?#{url}"
  end

  test "replaces urls" do
    assert Replacer.replace(
             """
             @import "./c.css";

             .test {
               background-image: url('d.css');
             }

             .test2 {
               background-image: url('../d.css');
             }
             """,
             &proxy_url/1,
             is_end: false
           ) ===
             {String.trim_trailing("""
              @import "http://proxy.com?./c.css";

              .test {
                background-image: url('http://proxy.com?d.css');
              }

              .test2 {
                background-image: url('http://proxy.com?../d.css');
              """),
              """

              }
              """}

    assert Replacer.replace(
             """
             @import "./c.css";

             .test {
               background-image: url('../d.cs
             """,
             &proxy_url/1,
             is_end: false
           ) === {
             "@import \"http://proxy.com?./c.css\";",
             """
             \n\n.test {
               background-image: url('../d.cs
             """
           }
  end

  test "when is_end=true" do
    assert Replacer.replace(
             """
             @import "./c.css";

             .test {
               background-image: url('../d.cs
             """,
             &proxy_url/1,
             is_end: true
           ) === {
             """
             @import "http://proxy.com?./c.css";

             .test {
               background-image: url('../d.cs
             """,
             ""
           }
  end
end
