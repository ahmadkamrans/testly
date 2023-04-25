# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Testly.Repo.insert!(%Testly.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Testly.Repo
alias Testly.Projects.Project
alias Testly.Accounts.User
alias Testly.Goals.Goal
alias Testly.SplitTests.{PageCategory, PageType}
alias Testly.IdeaLab.Category, as: IdeaLabCategory

Repo.transaction(fn ->
  user =
    Repo.insert!(%User{
      email: "user1@example.com",
      full_name: "John Smith",
      # password: qwerty
      encrypted_password: "$2b$12$yF3t4v8Glue9/N/pTeZ0Wus4M.G69hcVVKK2Rge6IzT8NvrghRdAK",
      is_admin: true
    })

  Repo.insert!(%Project{
    id: "98e01a0f-f7fc-4e02-a697-dd88b62d16b4",
    user_id: user.id,
    domain: "home-stage.testly.com"
  })

  Repo.insert!(%Project{
    id: "47c25d2f-dcc6-4fb8-89ab-38eb1d4c4267",
    user_id: user.id,
    domain: "testly.com"
  })

  Repo.insert!(%Project{
    id: "4ea112e7-9b45-4657-a9c5-4a163bf56a1c",
    user_id: user.id,
    domain: "dashboard"
  })

  %Project{id: project_id} =
    Repo.insert!(%Project{
      id: "13c68708-f216-469e-a599-2272f2f3be07",
      user_id: user.id,
      domain: "doodly.com"
    })

  Repo.insert!(%Goal{
    project_id: project_id,
    name: "Sale",
    value: 0,
    path: [
      %{
        index: 0,
        url: "one-time-price",
        match_type: :contains
      },
      %{
        index: 1,
        url: "onetime/offer",
        match_type: :contains
      },
      %{
        index: 2,
        url: "oto1",
        match_type: :contains
      }
    ],
    type: :path
  })

  page_type_entries =
    ["Landing Page", "Optin Form", "Order Form"]
    |> Enum.map(&%{id: Ecto.UUID.generate(), name: &1})

  page_category_entries =
    [
      "Automotive",
      "Computers/Internet",
      "Real Estate",
      "Politics",
      "Travel",
      "Education",
      "Arts & Entertainment",
      "Shopping",
      "Health/Fitness",
      "Business",
      "Finance",
      "Food & Drink",
      "Home & Family",
      "Pets",
      "Sports",
      "Other"
    ]
    |> Enum.map(&%{id: Ecto.UUID.generate(), name: &1})

  Repo.insert_all(PageType, page_type_entries)
  Repo.insert_all(PageCategory, page_category_entries)

  idea_lab_categories =
    [
      %{name: "E-COMMERCE", color: "#f48169"},
      %{name: "LONG FORM SALES PAGE", color: "#333b43"},
      %{name: "CHECKOUT", color: "#f6b63f"},
      %{name: "EMAIL", color: "#95d9f2"},
      %{name: "LANDING PAGE", color: "#ec6651"},
      %{name: "GRAPHICS & VIDEOS", color: "#5c6369"},
      %{name: "MOBILE", color: "#fecf67"},
      %{name: "FACEBOOK ADS", color: "#59b6db"},
      %{name: "PPC ADS", color: "#f48169"},
      %{name: "VIDEO SALES LETTER", color: "#333b43"},
      %{name: "SOCIAL MEDIA", color: "#f6b63f"},
      %{name: "WEBSITE NAVIGATION", color: "#95d9f2"},
      %{name: "MOBILE APPS", color: "#ec6651"}
    ]
    |> Enum.map(
      &%{
        id: Ecto.UUID.generate(),
        name: &1.name,
        color: &1.color,
        created_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }
    )

  Repo.insert_all(IdeaLabCategory, idea_lab_categories)
end)
