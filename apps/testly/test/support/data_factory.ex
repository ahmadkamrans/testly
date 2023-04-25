defmodule Testly.DataFactory do
  use ExMachina.Ecto, repo: Testly.Repo
  use Testly.AccountsFactory
  use Testly.SplitTestsFactory
  use Testly.GoalsFactory
  use Testly.SessionRecordingsFactory
  use Testly.SessionEventsFactory
  use Testly.ProjectsFactory
  use Testly.HeatmapsFactory
  use Testly.FeedbackFactory
end
