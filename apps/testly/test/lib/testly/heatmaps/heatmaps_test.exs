defmodule Testly.HeatmapsTest do
  use Testly.DataCase

  alias Testly.Heatmaps
  alias Testly.Heatmaps.{Page, Snapshot, View, ViewsCount}

  describe "#get_pages/1" do
    test "works" do
      project = insert(:project)
      page = insert(:heatmap_page, project_id: project.id)
      snapshot = insert(:heatmap_snapshot, page: page)
      snapshot2 = insert(:heatmap_snapshot, page: page, device_type: :mobile)
      insert(:heatmap_view, snapshot: snapshot)
      insert_list(2, :heatmap_view, snapshot: snapshot2)

      response = Heatmaps.get_pages(project)

      assert [
               %Page{
                 views_count: %ViewsCount{
                   total: 3,
                   mobile: 2,
                   desktop: 1,
                   tablet: 0
                 }
               }
             ] = response
    end
  end

  describe "#get_page/2" do
    test "works" do
      project = insert(:project)
      page = insert(:heatmap_page, project_id: project.id)
      snapshot = insert(:heatmap_snapshot, page: page)
      snapshot2 = insert(:heatmap_snapshot, page: page, device_type: :mobile)
      insert(:heatmap_view, snapshot: snapshot)
      insert(:heatmap_view, snapshot: snapshot2)

      response = Heatmaps.get_page(page.id)

      assert %Page{
               views_count: %ViewsCount{
                 total: 2,
                 mobile: 1,
                 desktop: 1,
                 tablet: 0
               }
             } = response
    end
  end

  describe "#track/2" do
    setup [:insert_ready_session_recording]

    test "no page, no snapshot, no view", %{project: _project, session_recording: session_recording} do
      session_recording_page = List.first(session_recording.pages)

      response = Heatmaps.track(session_recording, session_recording_page)

      assert {:ok,
              %{
                page: %Page{},
                snapshot: %Snapshot{},
                view: %View{}
              }} = response
    end

    test "yes page, yes snapshot, yes view", %{project: _project, session_recording: session_recording} do
      session_recording_page = List.first(session_recording.pages)

      Heatmaps.track(session_recording, session_recording_page)
      response = Heatmaps.track(session_recording, session_recording_page)

      assert {:ok,
              %{
                page: %Page{},
                snapshot: %Snapshot{},
                view: %View{}
              }} = response
    end

    test "yes page, no snapshot, no view", %{project: project, session_recording: session_recording} do
      session_recording_page = List.first(session_recording.pages)
      insert(:heatmap_page, project_id: project.id, url: session_recording_page.url)

      response = Heatmaps.track(session_recording, session_recording_page)

      assert {:ok,
              %{
                page: %Page{},
                snapshot: %Snapshot{},
                view: %View{}
              }} = response
    end
  end
end
