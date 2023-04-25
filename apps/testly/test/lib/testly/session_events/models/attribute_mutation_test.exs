defmodule Testly.SessionEvents.AttributeMutationTest do
  use Testly.DataCase, async: true

  alias Testly.SessionEvents.{AttributeMutation}

  describe "#changeset/2" do
    test "empty strings saved properly" do
      params = %{"value" => ""}

      changeset = AttributeMutation.changeset(%AttributeMutation{}, params)

      assert "" === Changeset.get_change(changeset, :value)
    end
  end
end
