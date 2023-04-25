defmodule TestlyAPI.Schema.Mock do
  def goals do
    %{
      "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267" => %{
        id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
        name: "Goal 1",
        path: [
          %{url: "eeee", match_type: :contains, index: 0},
          %{url: "wer", match_type: :contains, index: 1}
        ]
      },
      "ff5a15f6-513e-4316-a87d-fb72203e9bf0" => %{
        id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
        name: "Goal 2",
        path: [
          %{url: "eeee", match_type: :contains, index: 0},
          %{url: "wer", match_type: :contains, index: 1}
        ]
      }
    }
  end

  def split_test(id \\ nil) do
    %{
      id: id || "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
      name: "Suport lonh test name wow wow wow wow wow wow",
      description: "test description",
      allowed_device_types: [:desktop],
      allowed_traffic_sources: [:direct],
      traffic_percent: 0.5,
      page_category: %{
        id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
        name: "test category"
      },
      page_type: %{
        id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
        name: "test test type"
      },
      state: :active,
      variations: [
        %{
          id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          name: "www.doodle.com/version2 erfwerg werg wergrewrg werg",
          url: "http://www.doodle.com/version21",
          control: true
        },
        %{
          id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4268",
          name: "www.doodle.com/version2 erfwerg werg wergrewrg werg",
          url: "http://www.doodle.com/version23",
          control: false
        },
        %{
          id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          name: "Heavy Duty Steel Table",
          url: "http://shields.com/alysa",
          control: false
        }
      ],
      variations_conversions: [
        %{
          conversion_rate: 0.949,
          conversions: 13,
          visitors: 137,
          revenue: 0,
          # means baseline
          improvement: nil,
          winner: false,
          variation_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          goal_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0.1
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.15
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.2
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.2
            }
          ]
        },
        %{
          conversion_rate: 0.01,
          conversions: 13,
          visitors: 137,
          revenue: 0,
          # means baseline
          improvement: -0.1,
          winner: false,
          goal_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          variation_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4268",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0.1
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.15
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.2
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.2
            }
          ]
        },
        %{
          conversion_rate: 0.124,
          conversions: 13,
          visitors: 137,
          revenue: 0,
          improvement: 0.31,
          winner: true,
          goal_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          variation_id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0.25
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0.16
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.13
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.14
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.1
            }
          ]
        },
        %{
          conversion_rate: 0.5,
          conversions: 300,
          visitors: 137,
          revenue: 0,
          # means baseline
          improvement: nil,
          winner: true,
          goal_id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          variation_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.3
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.6
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.9
            }
          ]
        },
        %{
          conversion_rate: 0.949,
          conversions: 300,
          visitors: 137,
          revenue: 0,
          # means baseline
          improvement: -0.2,
          winner: false,
          goal_id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          variation_id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4268",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.3
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.6
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.9
            }
          ]
        },
        %{
          conversion_rate: 0.321,
          conversions: 10,
          visitors: 15,
          revenue: 0,
          improvement: 0.2,
          winner: false,
          goal_id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          variation_id: "ff5a15f6-513e-4316-a87d-fb72203e9bf0",
          rates_by_date: [
            %{
              date: elem(DateTime.from_iso8601("2018-12-08 00:00:00Z"), 1),
              conversion_rate: 0.1
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-10 00:00:00Z"), 1),
              conversion_rate: 0.2
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-14 00:00:00Z"), 1),
              conversion_rate: 0.3
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-15 00:00:00Z"), 1),
              conversion_rate: 0.4
            },
            %{
              date: elem(DateTime.from_iso8601("2018-12-18 00:00:00Z"), 1),
              conversion_rate: 0.5
            }
          ]
        }
      ],
      goals: Enum.map(goals(), fn {_, goal} -> goal end),
      finish_condition: %{
        times: 5,
        goal: %{
          id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
          name: "Goal 1"
        }
      }
    }
  end
end
