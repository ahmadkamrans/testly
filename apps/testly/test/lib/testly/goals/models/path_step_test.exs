defmodule Testly.Goals.PathStepTest do
  use Testly.DataCase

  alias Testly.Goals.PathStep

  describe "#changeset/2" do
    test "valid" do
      params = %{
        index: 0,
        url: "example.com",
        match_type: :contains
      }

      response = PathStep.changeset(%PathStep{}, params)

      assert %{valid?: true} = response
    end
  end

  describe "#match?/2" do
    test "matches_exactly" do
      assert PathStep.match?(%PathStep{match_type: :matches_exactly, url: "example.com"}, "example.com")
      refute PathStep.match?(%PathStep{match_type: :matches_exactly, url: "example"}, "example.com")
    end

    test "contains" do
      assert PathStep.match?(%PathStep{match_type: :contains, url: "example"}, "example.com")
      refute PathStep.match?(%PathStep{match_type: :contains, url: "another"}, "example.com")
    end

    test "begins_with" do
      assert PathStep.match?(%PathStep{match_type: :begins_with, url: "example"}, "example.com")
      refute PathStep.match?(%PathStep{match_type: :begins_with, url: "com"}, "example.com")
    end

    test "ends_with" do
      assert PathStep.match?(%PathStep{match_type: :ends_with, url: ".com"}, "example.com")
      refute PathStep.match?(%PathStep{match_type: :ends_with, url: "example"}, "example.com")
    end
  end
end
