defmodule Testly.Goals.PathGoalTest do
  @moduledoc """
    Don't test PathGoal API directly, use Goal API
  """
  use Testly.DataCase
  import Testly.DataFactory

  alias Testly.Goals.{Goal, PathGoal, PathStep, SessionRecording, Page}

  describe "changeset/2" do
    test "works" do
      params = string_params_for(:goal)

      changeset = Goal.changeset(assoc_id, params)

      assert %{valid?: true} = changeset
    end
  end

  describe "check_conversion/2" do
    test "true - full match" do
      goal = %PathGoal{
        path: [
          %PathStep{
            index: 0,
            url: "/registration",
            match_type: :contains
          },
          %PathStep{
            index: 1,
            url: "/success",
            match_type: :contains
          }
        ]
      }

      session_recording = %SessionRecording{
        pages: [
          %Page{
            url: "http://example.com/registration"
          },
          %Page{
            url: "http://example.com/success"
          }
        ]
      }

      response = Goal.check_conversion(goal, session_recording)

      assert response
    end

    test "true - reached again after partial match" do
      goal = %PathGoal{
        path: [
          %PathStep{
            index: 0,
            url: "/registration",
            match_type: :contains
          },
          %PathStep{
            index: 1,
            url: "/success",
            match_type: :contains
          }
        ]
      }

      session_recording = %SessionRecording{
        pages: [
          %Page{
            url: "http://example.com/registration"
          },
          %Page{
            url: "http://example.com/registration"
          },
          %Page{
            url: "http://example.com/success"
          }
        ]
      }

      response = Goal.check_conversion(goal, session_recording)

      assert response
    end

    test "false" do
      goal = %PathGoal{
        path: [
          %PathStep{
            index: 0,
            url: "/registration",
            match_type: :contains
          },
          %PathStep{
            index: 0,
            url: "/cancel",
            match_type: :contains
          }
        ]
      }

      session_recording = %SessionRecording{
        pages: [
          %Page{
            url: "http://example.com/registration"
          },
          %Page{
            url: "http://example.com/success"
          }
        ]
      }

      response = Goal.check_conversion(goal, session_recording)

      refute response
    end
  end
end
