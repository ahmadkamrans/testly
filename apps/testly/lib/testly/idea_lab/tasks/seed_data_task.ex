defmodule Testly.IdeaLab.SeedDataTask do
  alias NimbleCSV.RFC4180, as: CSV
  alias Testly.Repo
  alias Testly.IdeaLab
  alias Testly.IdeaLab.{Idea, Cover, IdeaQuery}

  @categories_map %{
    "1" => "E-COMMERCE",
    "2" => "LONG FORM SALES PAGE",
    "3" => "CHECKOUT",
    "4" => "EMAIL",
    "5" => "LANDING PAGE",
    "6" => "GRAPHICS & VIDEOS",
    "7" => "MOBILE",
    "8" => "FACEBOOK ADS",
    "9" => "PPC ADS",
    "10" => "VIDEO SALES LETTER",
    "11" => "SOCIAL MEDIA",
    "12" => "WEBSITE NAVIGATION",
    "13" => "MOBILE APPS"
  }

  def run do
    categories = IdeaLab.get_categories()

    "apps/testly/priv/test_ideas.csv"
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [
                       id,
                       title,
                       description,
                       category_id,
                       _user_id,
                       impact_rate,
                       _is_default,
                       _created_at,
                       _updated_at,
                       image_file_name,
                       _image_content_type,
                       _image_file_size,
                       _image_updated_at
                     ] ->
      query =
        IdeaQuery.from_idea()
        |> IdeaQuery.where_title_cont(title)

      if Repo.exists?(query) do
        nil
      else
        %Idea{
          id: Ecto.UUID.generate(),
          title: title,
          category_id: find_category_id(category_id, categories),
          description: description,
          impact_rate: String.to_integer(impact_rate),
          cover: %{file_name: image_file_name, updated_at: nil},
          cover_url: generate_source_url(id, image_file_name)
        }
      end
    end)
    |> Enum.each(fn idea ->
      if idea do
        Repo.transaction(fn ->
          Repo.insert(idea)
          Cover.store({idea.cover_url, idea})
        end)
      end
    end)

    :ok
  end

  defp find_category_id(source_category_id, categories) do
    category_name = @categories_map[source_category_id]

    Enum.find(categories, fn category ->
      category.name === category_name
    end).id
  end

  defp generate_source_url(id, image_file_name) do
    "https://s3.us-east-2.amazonaws.com/testlycom/test_ideas/images/000/"
    |> add_thousand_folder(id)
    |> add_id_folder(id)
    |> add_filename(image_file_name)

    # Idea.changeset(%Idea{}, params)
  end

  defp add_thousand_folder(url, id) do
    int_id = String.to_integer(id)
    folder = if(int_id < 1000, do: "000/", else: "001/")
    url <> folder
  end

  defp add_id_folder(url, id) do
    int_id = String.to_integer(id)

    id_folder =
      cond do
        int_id < 10 -> "00" <> id
        int_id < 100 -> "0" <> id
        int_id < 1000 -> id
        int_id < 1010 -> "00" <> id
        int_id < 1100 -> "0" <> id
      end

    url <> id_folder
  end

  defp add_filename(url, image_file_name) do
    url <> "/original/#{image_file_name}"
  end
end
