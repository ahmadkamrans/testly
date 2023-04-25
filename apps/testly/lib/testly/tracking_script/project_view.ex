defmodule Testly.TrackingScript.ProjectView do
  def render(%{project: project, split_tests: split_tests, polls: polls}) do
    %{
      id: project.id,
      is_recording_enabled: project.is_recording_enabled,
      split_tests: split_tests(split_tests),
      polls: polls(polls)
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

  defp polls(polls) do
    Enum.map(
      polls,
      &%{
        id: &1.id,
        thank_you_message: &1.thank_you_message,
        is_page_matcher_enabled: &1.is_page_matcher_enabled,
        show_poll_option: &1.show_poll_option,
        is_poll_opened_on_start: &1.is_poll_opened_on_start,
        questions: questions(&1.questions),
        page_matchers: page_matchers(&1.page_matchers)
      }
    )
  end

  defp questions(questions) do
    Enum.map(
      questions,
      &%{
        id: &1.id,
        type: &1.type,
        title: &1.title
      }
    )
  end

  defp page_matchers(page_matchers) do
    Enum.map(
      page_matchers,
      &%{
        match_type: &1.match_type,
        url: &1.url
      }
    )
  end
end
