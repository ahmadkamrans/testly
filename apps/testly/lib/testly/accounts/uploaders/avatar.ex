defmodule Testly.Accounts.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  @versions [:original, :thumb]

  def transform(:thumb, _) do
    {:convert,
     "-limit area 10MB -limit disk 100MB -strip -thumbnail 250x250^ -gravity center -extent 250x250 -quality 95"}
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def filename(version, {_file, _scope}) do
    version
  end

  def storage_dir(_, {_file, user}) do
    "uploads/avatars/#{user.id}"
  end
end
