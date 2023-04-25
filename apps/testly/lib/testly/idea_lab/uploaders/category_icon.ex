defmodule Testly.IdeaLab.CategoryIcon do
  use Arc.Definition
  use Arc.Ecto.Definition

  # @versions [:original]
  @extension_whitelist ~w(.svg)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def filename(version, {_file, _scope}) do
    version
  end

  def storage_dir(_, {_file, category}) do
    "uploads/category_icons/#{category.id}"
  end
end
