# TODO: Review this
# defmodule Testly.SessionRecordings.FilterTest do
#   use Testly.DataCase, async: true
#   import Testly.DataFactory

#   import Ecto.Query, only: [order_by: 2]

#   alias Testly.SessionRecordings.SplitTest.{VariationVisit, GoalConversion, Variation}
#   alias Testly.SessionRecordings.{Filter, Location, Device}
#   alias Testly.Repo

#   setup :insert_records

#   def filter(filter) do
#     filter
#     |> Filter.filter()
#     |> order_by(asc: :created_at)
#     |> Repo.all()
#     |> Enum.map(fn %{id: id} -> id end)
#   end

#   test "created_at_gteq filter", %{session_recordings: [_, first, second]} do
#     assert filter(%Filter{created_at_gteq: ~N[2015-01-15 13:00:00.000000Z]}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "created_at_lteq filter", %{session_recordings: [first, second, _]} do
#     assert filter(%Filter{created_at_lteq: ~N[2015-01-16 13:00:00.000000Z]}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "duration_gteq filter", %{session_recordings: [_, first, second]} do
#     assert filter(%Filter{duration_gteq: 20}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "duration_lteq filter", %{session_recordings: [first, second, _]} do
#     assert filter(%Filter{duration_lteq: 20}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "location_country_iso_code_in filter", %{session_recordings: [first, _, second]} do
#     assert filter(%Filter{location_country_iso_code_in: ["RU", "UA"]}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "device_type_in filter", %{session_recordings: [_, first, second]} do
#     assert filter(%Filter{device_type_in: [:mobile, :tablet]}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "referrer_source_in filter", %{session_recordings: [first, _, second]} do
#     assert filter(%Filter{referrer_source_in: [:social, :direct]}) == [
#              first.id,
#              second.id
#            ]
#   end

#   test "split_test_id_eq filter", %{split_test: split_test, session_recordings: [first, _, _]} do
#     assert filter(%Filter{split_test_id_eq: split_test.id}) == [
#              first.id
#            ]
#   end

#   def insert_records(_) do
#     project = insert(:project)
#     split_test = insert(:split_test, %{project_id: project.id})
#     split_test_goal = insert(:split_test_path_goal, %{split_test_id: split_test.id})

#     sr1 =
#       insert(:session_recording, %{
#         project_id: project.id,
#         created_at: ~N[2015-01-13 13:00:00.000000Z],
#         duration: 10,
#         referrer_source: :social,
#         location: %Location{
#           country_iso_code: "RU"
#         },
#         device: %Device{
#           type: :desktop
#         },
#         split_test_variation_visits: [
#           %VariationVisit{
#             variation: %Variation{
#               name: "test",
#               url: "http://google.com",
#               split_test_id: split_test.id
#             },
#             goal_conversions: [
#               %GoalConversion{
#                 split_test_goal_id: split_test_goal.id
#               }
#             ]
#           }
#         ]
#       })

#     sr2 =
#       insert(:session_recording, %{
#         project_id: project.id,
#         created_at: ~N[2015-01-15 13:00:00.000000Z],
#         duration: 20,
#         referrer_source: :search,
#         location: %Location{
#           country_iso_code: "US"
#         },
#         device: %Device{
#           type: :mobile
#         }
#       })

#     sr3 =
#       insert(:session_recording, %{
#         project_id: project.id,
#         created_at: ~N[2015-01-17 13:00:00.000000Z],
#         duration: 30,
#         referrer_source: :direct,
#         location: %Location{
#           country_iso_code: "UA"
#         },
#         device: %Device{
#           type: :tablet
#         }
#       })

#     %{session_recordings: [sr1, sr2, sr3], split_test_goal: split_test_goal, split_test: split_test}
#   end
# end
