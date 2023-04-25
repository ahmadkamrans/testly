defmodule Testly.Repo.Migrations.CreateEnums do
  use Ecto.Migration

  alias Testly.SessionEvents.EventTypeEnum
  alias Testly.SessionRecordings.{ReferrerSourceEnum, DeviceTypeEnum}
  alias Testly.Goals.{GoalTypeEnum, MatchTypeEnum}
  alias Testly.SplitTests.{SplitTestStatusEnum, FinishConditionTypeEnum}

  def up do
    EventTypeEnum.create_type()
    ReferrerSourceEnum.create_type()
    DeviceTypeEnum.create_type()
    GoalTypeEnum.create_type()
    MatchTypeEnum.create_type()
    SplitTestStatusEnum.create_type()
    FinishConditionTypeEnum.create_type()
  end

  def down do
    EventTypeEnum.drop_type()
    ReferrerSourceEnum.drop_type()
    DeviceTypeEnum.drop_type()
    GoalTypeEnum.drop_type()
    MatchTypeEnum.drop_type()
    SplitTestStatusEnum.drop_type()
    FinishConditionTypeEnum.drop_type()
  end
end
