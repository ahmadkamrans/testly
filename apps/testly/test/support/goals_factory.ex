defmodule Testly.GoalsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Goals.{
        PathGoal,
        PathStep,
        ProjectGoal,
        SplitTestGoal,
        ProjectGoalConversion,
        SplitTestGoalConversion,
        Conversion
      }

      def project_path_goal_factory do
        %ProjectGoal{
          type: :path,
          name: "name",
          path: [
            build(:path_step)
          ]
        }
      end

      def project_goal_conversion_factory do
        %ProjectGoalConversion{
          happened_at: DateTime.utc_now()
        }
      end

      def split_test_goal_conversion_factory do
        %SplitTestGoalConversion{
          happened_at: DateTime.utc_now()
        }
      end

      def split_test_path_goal_factory do
        %SplitTestGoal{
          type: :path,
          name: "name",
          value: Decimal.from_float(0.0),
          path: [
            build(:path_step)
          ]
        }
      end

      def path_goal_factory do
        %PathGoal{
          name: "Registration",
          path: [
            build(:path_step)
          ]
        }
      end

      def path_step_factory do
        %PathStep{
          index: 0,
          url: "example.com/login",
          match_type: :contains
        }
      end

      def goal_conversion_factory do
        %Conversion{
          happened_at: DateTime.utc_now()
        }
      end
    end
  end
end
