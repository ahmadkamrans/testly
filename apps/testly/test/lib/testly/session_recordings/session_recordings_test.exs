defmodule Testly.SessionRecordingsTest do
  use Testly.DataCase
  import Testly.DataFactory

  alias Testly.SessionRecordings
  alias Testly.SessionRecordings.{Filter, SessionRecording, Device, Location, Page}
  alias Testly.SessionEvents.EventSchema
  alias Testly.Goals.ProjectGoalConversion
  alias Testly.SessionRecordings.SplitTest.{VariationVisit, GoalConversion, Variation}
  alias Testly.Feedback.Response

  describe "#get_next_session_recording/1" do
    test "works" do
      [next, current, _] = insert_records_for_navigation_testing()

      assert next.created_at ===
               SessionRecordings.get_next_session_recording(current.id).created_at
    end
  end

  describe "#get_previous_session_recording/1" do
    test "works" do
      [_, current, previous] = insert_records_for_navigation_testing()

      assert previous.created_at ===
               SessionRecordings.get_previous_session_recording(current.id).created_at
    end
  end

  def insert_records_for_navigation_testing do
    project = insert(:project)

    next =
      insert(:session_recording, %{
        project_id: project.id,
        created_at: ~N[2015-01-13 13:00:00.000000Z]
      })

    current =
      insert(:session_recording, %{
        project_id: project.id,
        created_at: ~N[2015-01-15 13:00:00.000000Z]
      })

    previous =
      insert(:session_recording, %{
        project_id: project.id,
        created_at: ~N[2015-01-17 13:00:00.000000Z]
      })

    # project =
    #   insert(:project, %{
    #     session_recordings: [
    #       build(:session_recording, %{created_at: ~N[2015-01-13 13:00:00.000000Z]}),
    #       build(:session_recording, %{created_at: ~N[2015-01-15 13:00:00.000000Z]}),
    #       build(:session_recording, %{created_at: ~N[2015-01-17 13:00:00.000000Z]})
    #     ]
    #   })

    # Make sure that next/prev records will be from one project
    project2 = insert(:project)

    insert(:session_recording, %{
      project_id: project2.id,
      created_at: ~N[2015-01-14 13:00:00.000000Z]
    })

    insert(:session_recording, %{
      project_id: project2.id,
      created_at: ~N[2015-01-16 13:00:00.000000Z]
    })

    # insert(:project, %{
    #   session_recordings: [
    #     build(:session_recording, %{created_at: ~N[2015-01-14 13:00:00.000000Z]}),
    #     build(:session_recording, %{created_at: ~N[2015-01-16 13:00:00.000000Z]})
    #   ]
    # })

    # project.session_recordings
    [next, current, previous]
  end

  describe "get_project_avg_session_recordings_duration/1" do
    test "returns duration" do
      project = insert(:project)

      insert(:session_recording, %{project_id: project.id, duration: 1001})
      insert(:session_recording, %{project_id: project.id, duration: 1007})
      insert(:session_recording, %{project_id: project.id, duration: 1003})

      duration = SessionRecordings.get_project_avg_session_recordings_duration(project.id)

      assert duration == 1003
    end

    test "returns 0 if session_recordings are blank" do
      project = insert(:project)

      duration = SessionRecordings.get_project_avg_session_recordings_duration(project.id)

      assert duration == 0
    end
  end

  describe "get_project_avg_session_recordings_clicks_count/1" do
    test "returns duration" do
      project = insert(:project)
      insert(:session_recording, %{project_id: project.id, clicks_count: 1})
      insert(:session_recording, %{project_id: project.id, clicks_count: 4})
      insert(:session_recording, %{project_id: project.id, clicks_count: 3})

      count = SessionRecordings.get_project_avg_session_recordings_clicks_count(project.id)

      assert count == 2
    end

    test "returns 0 if session_recordings are blank" do
      project = insert(:project)

      count = SessionRecordings.get_project_avg_session_recordings_clicks_count(project.id)

      assert count == 0
    end
  end

  describe "get_project_session_recordings_count/1" do
    test "returns count" do
      project = insert(:project)
      insert_pair(:session_recording, %{project_id: project.id})

      count = SessionRecordings.get_project_session_recordings_count(project.id)

      assert count == 2
    end
  end

  describe "get_session_recording/1" do
    test "returns session recording" do
      project = insert(:project)
      session_recording = insert(:session_recording, %{project_id: project.id})

      response = SessionRecordings.get_session_recording(session_recording.id)

      assert %SessionRecording{
               location: %Location{},
               device: %Device{}
             } = response
    end
  end

  describe "get_project_session_recordings/1" do
    test "returns project's session recordings" do
      project = insert(:project)
      insert_pair(:session_recording, %{project_id: project.id})

      session_recordings =
        SessionRecordings.get_project_session_recordings(
          project.id,
          page: 1,
          per_page: 2,
          filter: %Filter{}
        )

      assert Enum.count(session_recordings) == 2

      session_recording = List.first(session_recordings)
      assert %Location{} = session_recording.location
      assert %Device{} = session_recording.device
    end
  end

  describe "create_session_recording/1" do
    test "valid params" do
      project = insert(:project)
      ip = "94.20.142.154"

      user_agent =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"

      params = %{
        referrer: nil,
        location: %{
          ip: ip
        },
        device: %{
          user_agent: user_agent,
          screen_height: 1600,
          screen_width: 900
        }
      }

      response = SessionRecordings.create_session_recording(project.id, params)

      assert {:ok,
              %SessionRecording{
                location: %Location{
                  city: "Baku",
                  country: "Azerbaijan",
                  latitude: 40.3953,
                  longitude: 49.8822,
                  country_iso_code: "AZ"
                },
                device: %Device{
                  os_name: "Windows",
                  os_version: "10",
                  browser_name: "Microsoft Edge",
                  browser_version: "12.246"
                }
              }} = response
    end

    test "invalid params" do
      response = SessionRecordings.create_session_recording("project_id", %{})

      assert {:error, %Ecto.Changeset{}} = response
    end
  end

  describe "calculate_pages/2" do
    test "create new pages" do
      datetime = DateTime.utc_now()
      project = insert(:project)
      session_recording = insert(:session_recording, project_id: project.id, pages: [])

      grouped_events = [
        [
          build(:page_visited_event, happened_at: datetime),
          build(:mouse_clicked_event, happened_at: Timex.shift(datetime, seconds: 1))
        ],
        [
          build(:page_visited_event, happened_at: Timex.shift(datetime, seconds: 2)),
          build(:mouse_clicked_event, happened_at: Timex.shift(datetime, seconds: 3))
        ]
      ]

      response = SessionRecordings.calculate_pages(session_recording, grouped_events)

      assert {:ok,
              [
                %Page{
                  duration: 2000
                },
                %Page{
                  duration: 1000
                }
              ]} = response
    end

    test "update existing page" do
      datetime = DateTime.utc_now()
      project = insert(:project)

      session_recording =
        insert(:session_recording,
          project_id: project.id,
          pages: [
            build(:session_recording_page, duration: 0, visited_at: datetime)
          ]
        )

      grouped_events = [
        [
          build(:mouse_clicked_event, happened_at: Timex.shift(datetime, seconds: 1))
        ],
        [
          build(:page_visited_event, happened_at: Timex.shift(datetime, seconds: 2)),
          build(:mouse_clicked_event, happened_at: Timex.shift(datetime, seconds: 3))
        ]
      ]

      response = SessionRecordings.calculate_pages(session_recording, grouped_events)

      assert {:ok,
              [
                %Page{
                  duration: 2000
                },
                %Page{
                  duration: 1000
                }
              ]} = response
    end
  end

  describe "get_staled_recording_ids/1" do
    test "returns staled recording ids" do
      project = insert(:project)

      insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -3))
      insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -10))
      s_r3 = insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -31))
      s_r4 = insert(:session_recording, project_id: project.id, created_at: Timex.shift(DateTime.utc_now(), days: -40))

      assert Enum.sort(SessionRecordings.get_staled_recording_ids(limit: 1000)) === Enum.sort([s_r4.id, s_r3.id])
      assert SessionRecordings.get_staled_recording_ids(limit: 1) === [s_r3.id]
    end
  end

  describe "delete_recordings/1" do
    test "returns amount of deleted recordings" do
      project = insert(:project)

      s_r1 = insert(:session_recording, project_id: project.id)
      s_r2 = insert(:session_recording, project_id: project.id)

      assert SessionRecordings.delete_recordings([s_r1.id, s_r2.id]) === 2
    end

    test "doesn't delete feedback responses" do
      project = insert(:project)
      %{id: session_recording_id} = insert(:session_recording, project_id: project.id)

      %{responses: [%{id: response_id}]} =
        insert(:feedback_poll,
          project_id: project.id,
          responses: [build(:feedback_response, session_recording_id: session_recording_id)]
        )

      assert %Response{session_recording_id: ^session_recording_id} = Repo.get(Response, response_id)

      SessionRecordings.delete_recordings([session_recording_id])

      assert %Response{session_recording_id: nil} = Repo.get(Response, response_id)
    end

    test "doesn't delete split test variation visits" do
      project = insert(:project)
      split_test = insert(:split_test, %{project_id: project.id})
      split_test_goal = insert(:split_test_path_goal, %{split_test_id: split_test.id})

      %{split_test_variation_visits: [%{id: visit_id}], id: recording_id} =
        insert(:session_recording, %{
          project_id: project.id,
          split_test_variation_visits: [
            %VariationVisit{
              variation: %Variation{
                name: "test",
                url: "http://google.com",
                split_test_id: split_test.id
              },
              goal_conversions: [
                %GoalConversion{
                  split_test_goal_id: split_test_goal.id
                }
              ],
              visited_at: DateTime.utc_now()
            }
          ]
        })

      assert %VariationVisit{session_recording_id: ^recording_id} = Repo.get(VariationVisit, visit_id)

      SessionRecordings.delete_recordings([recording_id])

      assert %VariationVisit{session_recording_id: nil} = Repo.get(VariationVisit, visit_id)
    end

    test "doesn't delete project goal conversion" do
      project = insert(:project)
      %{id: session_recording_id} = insert(:session_recording, project_id: project.id)

      %{conversions: [%ProjectGoalConversion{id: conversion_id}]} =
        insert(:project_path_goal,
          project_id: project.id,
          conversions: [
            build(:project_goal_conversion, session_recording_id: session_recording_id)
          ]
        )

      assert %ProjectGoalConversion{session_recording_id: ^session_recording_id} =
               Repo.get(ProjectGoalConversion, conversion_id)

      SessionRecordings.delete_recordings([session_recording_id])

      assert %ProjectGoalConversion{session_recording_id: nil} = Repo.get(ProjectGoalConversion, conversion_id)
    end

    test "deletes location" do
      session_recording = insert(:session_recording, project_id: insert(:project).id)

      SessionRecordings.delete_recordings([session_recording.id])

      assert Repo.get(Location, session_recording.location.id) === nil
    end

    test "deletes device" do
      session_recording = insert(:session_recording, project_id: insert(:project).id)

      SessionRecordings.delete_recordings([session_recording.id])

      assert Repo.get(Device, session_recording.device.id) === nil
    end

    test "deletes pages" do
      session_recording =
        insert(:session_recording,
          project_id: insert(:project).id,
          pages: [build(:session_recording_page)]
        )

      SessionRecordings.delete_recordings([session_recording.id])

      assert Repo.get(Page, List.first(session_recording.pages).id) === nil
    end

    test "deletes recording events" do
      session_recording =
        insert(:session_recording,
          project_id: insert(:project).id,
          pages: [build(:session_recording_page)]
        )

      event =
        insert(:page_visited_event_schema,
          session_recording_id: session_recording.id,
          page_id: List.first(session_recording.pages).id
        )

      SessionRecordings.delete_recordings([session_recording.id])

      assert Repo.get(EventSchema, event.id) === nil
    end
  end

  # describe "track_session_recording/2" do
  #   test "all event types, duration, clicks_count" do
  #     unix_timestamp = System.system_time(:millisecond)
  #     new_unix_timestamp = unix_timestamp + 10_000

  #     project = insert(:project)
  #     session_recording = insert(:session_recording, project_id: project.id)

  #     events = [
  #       %{
  #         type: "page_visited",
  #         timestamp: unix_timestamp,
  #         data: %{origin: "example.com", url: "http://example.com/", title: "title", doc_type: "html", dom_snapshot: %{id: 123, node_type: 1}}
  #       },
  #       %{
  #         type: "dom_mutated",
  #         timestamp: new_unix_timestamp,
  #         data: %{origin: "example.com", attributes: [%{id: 123, name: "test"}]}
  #       },
  #       %{
  #         type: "mouse_clicked",
  #         timestamp: new_unix_timestamp,
  #         data: %{x: 1, y: 1, selector: "sel"}
  #       },
  #       %{type: "mouse_moved", timestamp: new_unix_timestamp, data: %{x: 1, y: 1}},
  #       %{type: "scrolled", timestamp: new_unix_timestamp, data: %{top: 1, left: 1, id: 1}},
  #       %{
  #         type: "window_resized",
  #         timestamp: new_unix_timestamp,
  #         data: %{height: 1, width: 1}
  #       }
  #     ]

  #     response = SessionRecordings.track_session_recording(session_recording, events)

  #     sr = SessionRecordings.get_session_recording(session_recording.id)

  #     assert :ok == response
  #     assert sr.duration == 10_000
  #     assert sr.clicks_count == 1
  #   end

  #   test "invalid events" do
  #     project = insert(:project)
  #     session_recording = insert(:session_recording, project_id: project.id)
  #     events = [%{type: "wrong_type"}]

  #     response = SessionRecordings.track_session_recording(session_recording, events)

  #     assert {:error, [%Changeset{}]} = response
  #   end
  # end
end
