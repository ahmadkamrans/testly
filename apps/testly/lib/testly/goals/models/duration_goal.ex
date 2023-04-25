# defmodule Testly.Goals.DurationGoal do
#   use Testly.Goals.Goal

#   goal_model do
#     field :type, GoalTypeEnum, default: :duration
#     field :duration, :integer
#   end

#   @spec goal_changeset(Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
#   def goal_changeset(changeset, params) do
#     changeset
#     |> cast(params, [:duration])
#     |> validate_number(:duration, greater_than_or_equal_to: 1)
#   end
# end
