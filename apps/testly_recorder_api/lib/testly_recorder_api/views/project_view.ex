defmodule TestlyRecorderAPI.ProjectView do
  use TestlyRecorderAPI, :view

  def render("project.json", %{project: project, split_tests: split_tests}) do
    %{
      id: project.id,
      is_recording_enabled: project.is_recording_enabled,
      split_tests: split_tests(split_tests)
    }
  end

  defp split_tests(split_tests) do
    Enum.map(
      split_tests,
      &%{
        id: &1.id,
        variations: variations(&1.variations),
        traffic_percent: &1.traffic_percent
      }
    )
  end

  defp variations(variations) do
    Enum.map(
      variations,
      &%{
        id: &1.id,
        url: &1.url,
        control: &1.control
      }
    )
  end
end
