defmodule Testly.GoalsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.Goals.{
        Goal,
        PathStep,
        Conversion
      }

      def path_goal_factory do
        %Goal{
          type: :path,
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
