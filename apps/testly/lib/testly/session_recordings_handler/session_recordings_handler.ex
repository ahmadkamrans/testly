defmodule Testly.SessionRecordingsHandler do
  alias Testly.SessionRecordings
  alias Testly.Goals
  alias Testly.SessionEvents
  alias Testly.Repo
  alias Ecto.Multi

  use Appsignal.Instrumentation.Decorators

  import Appsignal.Instrumentation.Helpers, only: [instrument: 3]

  @moduledoc ~S"""
  ## Workflow
  1. #track_session_recording will be called first. All created events will be
     is_processed === false
  2. Producer(only one in the whole cluster) will take not processed events on demand.
     It guarantees, that only one uniq SessionRecording will be handled per time. It achieved by:
     1. Only one Producer instance per cluster(guaranteed by DistributedSupervisor)
     2. Calling of all consumers about what SessionRecordings are handling by now
  3. Consumer will ask Producer every `n` seconds and will handle batch of the SessionRecording.
     It will be done asynchronously cause we also need to handle Producer call(:get_session_recording_ids_in_progres).
     Task.Supervisor.async_stream_nolink will be used, it will start `n` Tasks.
     SessionRecording processing fail will be ignored.

  ## Edge cases
  1. It will store and will not process failed to process SessionRecordings
  2. Consumer will be restarted again and again every 5 seconds if Producer is not available
  3. Producer will be restarted without any timeout again and again on any failure

  ## Guarantees
  1. Only one SessionRecording will be handled per time
  2. All SessionRecording will be handled, no matter if all servers will go down and then up

  ## TODO
  1. Use Horde.Registry instead of :pg2, to track which session recordings are in progress.
     Waiting for https://github.com/derekkraan/horde/issues/37 to resolve

  ## Buffering
  There is no events and demand buffering
  """

  @decorate transaction(:events_handling)
  def process_session_recording(session_recording) do
    Appsignal.Transaction.set_sample_data("tags", %{session_recording_id: session_recording.id})

    unprocessed_events = SessionEvents.get_unprocessed_events(session_recording.id)
    grouped_events = SessionEvents.group_events_by_page_visited(unprocessed_events)

    result =
      Multi.new()
      |> Multi.run(:pages, fn _repo, _changes ->
        instrument("SessionRecordings.calculate_pages", "Calculating pages", fn ->
          SessionRecordings.calculate_pages(session_recording, grouped_events)
        end)
      end)
      |> Multi.run(:events, fn _repo, %{pages: pages} ->
        instrument("SessionEvents.process_events", "Processing events", fn ->
          :ok = SessionEvents.process_events(pages, grouped_events)
          {:ok, "events"}
        end)
      end)
      |> Multi.run(:session_recording, fn _repo, _changes ->
        instrument("SessionRecordings.calculate_session_recording", "Calculating session recoridngs", fn ->
          SessionRecordings.calculate_session_recording(session_recording)
        end)
      end)
      |> Multi.run(:goals, fn _repo, _changes ->
        instrument("Goals.convert_goals", "Converting goals", fn ->
          session_recording = SessionRecordings.get_session_recording(session_recording.id)
          Goals.convert_goals(session_recording)
          {:ok, session_recording}
        end)
      end)
      |> Multi.run(:heatmaps, fn _repo, %{pages: pages} ->
        instrument("Heatmaps.track", "Tracking heatmaps", fn ->
          for page <- pages do
            Testly.Heatmaps.track(session_recording, page)
          end

          {:ok, "heatmaps"}
        end)
      end)
      |> Repo.transaction(timeout: 60_000)

    case result do
      {:ok, _changes} ->
        :ok

      {:error, :events, changesets, _changes} ->
        {:error, changesets}
    end
  end

  @callback track_session_recording(SessionRecording.t(), [map()]) :: :ok | {:error, [Ecto.Changeset.t()]}
  def track_session_recording(session_recording, events_params) do
    SessionEvents.create_events(session_recording.id, events_params)
  end
end
