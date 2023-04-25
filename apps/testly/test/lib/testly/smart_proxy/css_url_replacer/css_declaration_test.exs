defmodule Testly.SmartProxy.CssDeclarationTest do
  use ExUnit.Case, async: true

  alias Testly.SmartProxy.CssUrlReplacer.CssDeclaration

  test "when ; is not present" do
    assert CssDeclaration.find("@import 'fef") === {"", "@import 'fef"}
    assert CssDeclaration.find("@import 'fef;;;") === {"", "@import 'fef;;;"}
    assert CssDeclaration.find("@import 'fef;;; g") === {"", "@import 'fef;;; g"}
    assert CssDeclaration.find("@import 'fef;;; ") === {"", "@import 'fef;;; "}
  end

  test "when single/double quotes have `;`" do
    assert CssDeclaration.find("@import \"fef;") === {"", "@import \"fef;"}
    assert CssDeclaration.find("@import 'fef\"\"\\';") === {"", "@import 'fef\"\"\\';"}
  end

  test "when ; is present" do
    assert CssDeclaration.find("@import 'fef';") === {"@import 'fef';", ""}
    assert CssDeclaration.find("@import 'fef'; rerer") === {"@import 'fef';", " rerer"}
    assert CssDeclaration.find("@import 'fef'; test;") === {"@import 'fef'; test;", ""}
    assert CssDeclaration.find("@import 'fef'; test; ") === {"@import 'fef'; test;", " "}
    assert CssDeclaration.find("@import 'fef'; test';") === {"@import 'fef';", " test';"}
  end

  test "when comment is not ended" do
    assert CssDeclaration.find("/** @import 'fef';") === {"", "/** @import 'fef';"}
  end

  test "when comment contains qoute" do
    assert CssDeclaration.find("/** ' */@import 'fef';") === {"/** ' */@import 'fef';", ""}
  end

  test "when comment mutlilined" do
    assert CssDeclaration.find("/***\n\n**/;") === {"/***\n\n**/;", ""}
  end

  test "(bug!) when comment inside of string" do
    assert CssDeclaration.find("content: \"/***\n\n**/\";") === {"content: \"/***\n\n**/\";", ""}
  end

  test "(bug!) when not closed comment inside of string" do
    assert CssDeclaration.find("content: \"/***\";") === {"content: \"/***\";", ""}
  end
end
