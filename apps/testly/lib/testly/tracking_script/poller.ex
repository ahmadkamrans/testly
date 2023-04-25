defmodule Testly.TrackingScript.Poller do
  use GenServer
  require Logger

  alias Testly.TrackingScript.{
    SourceCacher,
    Script,
    Collector
  }

  alias Testly.Feedback

  @split_tests Application.get_env(:testly, Testly.SplitTests)[:impl]
  @projects Application.get_env(:testly, Testly.Projects)[:impl]
  @poll_interval :timer.minutes(1)

  def start_link(args \\ [], options \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, args, options)
  end

  @impl true
  def init(_args) do
    send(self(), :poll)

    Logger.info("Testly.TrackingScript.Poller: init")
    {:ok, %{}}
  end

  @impl true
  def handle_info(:poll, state) do
    script = SourceCacher.get_script()
    projects = @projects.get_projects()

    for project <- projects do
      split_tests = @split_tests.get_active_split_tests(project)
      polls = Feedback.get_active_polls(project)
      {hash, content} = Script.generate(script, project, split_tests, polls)

      if hash !== project.uploaded_script_hash do
        Logger.info("Testly.TrackingScript.Poller: Project #{project.id} has different hash, upload new sript")
        # TODO: Better update hash after successfull upload
        @projects.update_project_uploaded_script_hash(project, hash)
        Collector.upload({project.id, content})
      else
        Logger.info("Testly.TrackingScript.Poller: Project #{project.id} has the same hash, do nothing")
      end
    end

    schedule_poll()

    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(
      self(),
      :poll,
      @poll_interval
    )
  end
end
