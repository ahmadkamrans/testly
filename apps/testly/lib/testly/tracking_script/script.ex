defmodule Testly.TrackingScript.Script do
  alias Testly.TrackingScript.ProjectView

  alias Testly.Projects.Project
  alias Testly.SplitTests.SplitTest
  alias Testly.Feedback.Poll

  @spec store(String.t(), String.t()) :: {:ok, term()} | {:error, term()}
  def store(content, project_id) do
    Application.get_env(:testly, Testly.TrackingScript)[:bucket]
    |> ExAws.S3.put_object("#{project_id}.js", content, content_type: "text/javascript")
    |> ExAws.request()
  end

  @spec generate(String.t(), Project.t(), [SplitTest.t()], [Poll.t()]) :: {String.t(), String.t()}
  def generate(script, project, split_tests, polls) do
    project_data =
      ProjectView.render(%{project: project, split_tests: split_tests, polls: polls})
      |> ProperCase.to_camel_case()
      |> Jason.encode!()

    content = "window._TestlyProject = #{project_data};\n" <> script

    {hash(content), content}
  end

  defp hash(script) do
    :crypto.hash(:md5, script) |> Base.encode16()
  end
end
