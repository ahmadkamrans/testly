defmodule Testly.Heatmaps do
  alias Ecto.{Multi, Changeset}
  alias Testly.Repo
  alias Testly.Projects.{Project}

  alias Testly.Heatmaps.{
    PageQuery,
    SnapshotQuery,
    Page,
    Snapshot,
    PageFilter,
    PageOrder,
    Element
  }

  alias Testly.{SessionEvents, Pagination}
  alias Testly.SessionEvents.{MouseClickedEvent, PageVisitedEvent}
  alias Testly.SessionRecordings.SessionRecording
  alias Testly.SessionRecordings.Page, as: SessionRecordingPage

  import Appsignal.Instrumentation.Helpers, only: [instrument: 3]

  def get_pages(%Project{id: project_id}, options \\ []) do
    filter = struct(PageFilter, options[:filter] || %{})
    order = struct(PageOrder, options[:order] || %{})
    pagination = struct(Pagination, options[:pagination] || %{})

    PageQuery.from_page()
    |> PageQuery.join_snapshot()
    |> PageQuery.join_view()
    |> PageQuery.select_views_count()
    |> PageQuery.where_project_id(project_id)
    |> PageFilter.filter(filter)
    |> PageOrder.order(order)
    |> Pagination.paginate(pagination)
    |> Repo.all()
  end

  def get_pages_count(%Project{id: project_id}) do
    PageQuery.from_page()
    |> PageQuery.where_project_id(project_id)
    |> Repo.aggregate(:count, :id)
  end

  def get_page(id) do
    PageQuery.from_page()
    |> PageQuery.join_snapshot()
    |> PageQuery.join_view()
    |> PageQuery.select_views_count()
    |> Repo.get(id)
  end

  def get_snapshot(%Page{id: page_id}, device_type) do
    snapshot =
      SnapshotQuery.from_snapshot()
      |> SnapshotQuery.where_page_id(page_id)
      |> SnapshotQuery.where_device_type(device_type)
      |> SnapshotQuery.preload_assocs()
      |> Repo.one()

    elements =
      instrument("Heatmaps.get_snapshot", "Elements grouping", fn ->
        snapshot.views
        |> Enum.flat_map(& &1.elements)
        |> Element.group_elements()
      end)

    %{snapshot | elements: elements}
  end

  @spec track(SessionRecording.t(), SessionRecordingPage.t()) :: Page.t()
  def track(session_recording, session_recording_page) do
    uri = URI.parse(session_recording_page.url)
    uri_path = if uri.path === nil, do: "/", else: uri.path
    url = "#{uri.host}#{uri_path}"

    page = Repo.get_by(Page, url: url)

    events = SessionEvents.get_events(session_recording_page)
    click_events = Enum.filter(events, &match?(%MouseClickedEvent{}, &1))
    page_visited_event = Enum.find(events, &match?(%PageVisitedEvent{}, &1))

    elements =
      click_events
      |> Element.mouse_clicked_events_to_elements()
      |> Element.group_elements()

    case page do
      %Page{} = page ->
        snapshot =
          case Repo.get_by(Snapshot, page_id: page.id, device_type: session_recording.device.type) do
            %Snapshot{} = snapshot ->
              snapshot
              |> Changeset.change(%{
                doc_type: page_visited_event.data.doc_type
              })
              |> Changeset.put_embed(:dom_nodes, page_visited_event.data.dom_snapshot)
              |> Repo.update!()

            nil ->
              page
              |> Ecto.build_assoc(:snapshots, %{
                device_type: session_recording.device.type,
                doc_type: page_visited_event.data.doc_type,
                dom_nodes: page_visited_event.data.dom_snapshot
              })
              |> Repo.insert!()
          end

        view =
          snapshot
          |> Ecto.build_assoc(:views, %{
            session_recording_page_id: session_recording_page.id,
            visited_at: session_recording_page.visited_at,
            elements: elements
          })
          |> Repo.insert!(
            on_conflict: :replace_all_except_primary_key,
            conflict_target: [:session_recording_page_id]
          )

        {:ok,
         %{
           page: page,
           snapshot: snapshot,
           view: view
         }}

      nil ->
        Multi.new()
        |> Multi.insert(:page, fn _ ->
          %Page{
            project_id: session_recording.project_id,
            url: url
          }
        end)
        |> Multi.insert(:snapshot, fn %{page: page} ->
          Ecto.build_assoc(page, :snapshots, %{
            device_type: session_recording.device.type,
            doc_type: page_visited_event.data.doc_type,
            dom_nodes: page_visited_event.data.dom_snapshot
          })
        end)
        |> Multi.insert(:view, fn %{snapshot: snapshot} ->
          Ecto.build_assoc(snapshot, :views, %{
            session_recording_page_id: session_recording_page.id,
            visited_at: session_recording_page.visited_at,
            elements: elements
          })
        end)
        |> Repo.transaction()
    end
  end
end
