# defmodule Testly.Goals.Goal do
#   use Testly.Schema
#   import Ecto.Query

#   alias __MODULE__
#   alias Testly.Goals.{GoalTypeEnum}

#   # @split_test_goals_table "split_test_goals"
#   # @projects_table "project_goals"

#   @type t :: %Goal{
#           id: Testly.Schema.pk(),
#           # assoc_id: Testly.Schema.pk(),
#           project_id: Testly.Schema.pk(),
#           split_test_id: Testly.Schema.pk(),
#           name: String.t(),
#           value: pos_integer(),
#           path: [map()],
#           type: GoalTypeEnum.t(),
#           created_at: DateTime.t(),
#           updated_at: DateTime.t()
#         }

#   @modules %{
#     :path => Testly.Goals.PathGoal
#   }

#   @to_fields [:id, :name, :value, :created_at, :updated_at, :type, :path]
#   @to_type_fields [:id, :name, :value, :created_at, :updated_at]

#   schema "goals" do
#     # field :assoc_id, Ecto.UUID
#     field :project_id, Ecto.UUID
#     field :split_test_id, Ecto.UUID
#     field :name, :string
#     field :value, :float
#     field :type, GoalTypeEnum
#     field :path, {:array, :map}
#     timestamps()
#   end

#   @spec changeset(String.t(), map()) :: Changeset.t()
#   def changeset(assoc_id, params) do
#     case cast(%Goal{}, params, [:type]) do
#       %Changeset{valid?: true} = changeset ->
#         module = @modules[get_field(changeset, :type)]

#         module
#         |> struct(assoc_id: assoc_id)
#         |> module.changeset(params)

#       %Changeset{valid?: false} = changeset ->
#         changeset
#     end
#   end

#   @spec update_changeset(PathGoal.t(), map()) :: Changeset.t()
#   def update_changeset(schema, params) do
#     schema.__struct__.changeset(schema, params)
#   end

#   def to_type_goal(%Goal{} = goal) do
#     @modules[goal.type].to_type_goal(goal)
#   end

#   # def put_session_recordings(schema, session_recordings) do
#   #   schema
#   #   |> change
#   #   |> put_assoc(:session_recordings, session_recordings)
#   # end

#   # @spec check_if_reached(Goal.t(), SessionRecording.t()) :: boolean
#   # def check_if_reached(goal, session_recording) do
#   #   match_path(session_recording.pages, goal.path, goal.path)
#   # end

#   def from_goals do
#     from(g in Goal, as: :goal)
#   end

#   def where_split_test_id(query, split_test_id) do
#     where(query, [goal: g], g.split_test_id == ^split_test_id)
#   end

#   def order_by_created_at_desc(query) do
#     order_by(query, [goal: g], desc: g.created_at)
#   end

#   def to_split_test_goal(type_goal) do
#     params = Map.from_struct(type_goal)

#     %Goal{split_test_id: type_goal.assoc_id}
#     |> cast(params, @to_fields)
#   end

#   def to_project_goal(type_goal) do
#     params = Map.from_struct(type_goal)

#     %Goal{project_id: type_goal.assoc_id}
#     |> cast(params, @to_fields)
#   end

#   defmacro __using__(_) do
#     quote do
#       use Testly.Schema
#       alias Testly.Goals.GoalTypeEnum
#       import Testly.Goals.Goal, only: [goal_model: 1]
#     end
#   end

#   defmacro goal_model(do: block) do
#     quote do

#       @derive Jason.Encoder
#       @primary_key false
#       embedded_schema do
#         field :id, Ecto.UUID
#         field :assoc_id, Ecto.UUID
#         field :name, :string
#         field :value, :integer
#         timestamps()
#         unquote(block)
#       end

#       @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
#       def changeset(schema, params) do
#         schema
#         |> cast(params, [:name, :value])
#         |> validate_required([:name])
#         |> goal_changeset
#       end

#       def to_type_goal(%Goal{} = goal) do
#         assoc_id = goal.project_id || goal.split_test_id

#         struct(__MODULE__, assoc_id: assoc_id)
#         |> cast(Map.from_struct(goal), @to_type_fields)
#         # |> to_goal
#         |> Ecto.Changeset.apply_changes()
#       end
#     end
#   end
# end
