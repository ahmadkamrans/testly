defmodule Testly.IdeaLab.Cover do
  use Arc.Definition
  use Arc.Ecto.Definition

  # @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def filename(version, {_file, _scope}) do
    version
  end

  def storage_dir(_, {_file, idea}) do
    "uploads/idea_covers/#{idea.id}"
  end

  def default_url do
    "https://placehold.it/100x100"
  end
end
