defmodule Testly.IdeaLab do
  alias Ecto.Changeset
  alias Testly.{Repo, Pagination}

  alias Testly.Accounts.{User}

  alias Testly.IdeaLab.{
    Idea,
    Category,
    Like,
    IdeaQuery,
    LikeQuery,
    IdeaFilter,
    IdeaOrder,
    CategoryOrder,
    CategoryQuery
  }

  defmodule Behaviour do
    alias Testly.IdeaLab.{Idea, Category, Like}
    alias Testly.Accounts.{User}

    @callback get_idea(String.t()) :: Idea.t()
    @callback get_all_ideas() :: [Idea.t()]
    @callback get_ideas(keyword()) :: [Idea.t()]
    @callback get_ideas_count(keyword()) :: non_neg_integer()
    @callback create_idea(map()) :: Idea.t() | Changeset.t()
    @callback update_idea(Idea.t(), map()) :: Idea.t() | Changeset.t()
    @callback delete_idea(Idea.t()) :: Idea.t()
    @callback toggle_idea_like!(Idea.t(), User.t()) :: :ok
    @callback paginate_ideas(map()) :: {:ok, map()} | {:error, map()}

    @callback get_category(String.t()) :: Category.t()
    @callback get_categories() :: [Category.t()]
    @callback create_category(map()) :: Category.t() | Changeset.t()
    @callback update_category(Category.t(), map()) :: Category.t() | Changeset.t()
    @callback delete_category(Category.t()) :: Category.t()

    @callback get_likes(User.t()) :: [Like.t()]
    @callback is_liked?(Idea.t(), User.t()) :: boolean()
  end

  @behaviour Behaviour

  @impl true
  def get_idea(id) do
    Idea
    |> Repo.get(id)
    |> Repo.preload([:category])
  end

  @impl true
  def get_all_ideas do
    IdeaQuery.from_idea()
    |> Repo.all()
    |> Enum.map(&Idea.populate_cover_url/1)
  end

  @impl true
  # TODO: {:ok} tuple
  def get_ideas(params \\ %{}) do
    filter_changeset = IdeaFilter.changeset(%IdeaFilter{}, params[:filter] || params["filter"] || %{})
    pagination_changeset = Pagination.changeset(%Pagination{}, params[:pagination] || params["pagination"] || %{})
    order_changeset = IdeaOrder.changeset(%IdeaOrder{}, params[:order] || params["order"] || %{})

    with %Changeset{valid?: true} <- filter_changeset,
         %Changeset{valid?: true} <- pagination_changeset,
         %Changeset{valid?: true} <- order_changeset do
      filter = Changeset.apply_changes(filter_changeset)
      order = Changeset.apply_changes(order_changeset)
      pagination = Changeset.apply_changes(pagination_changeset)

      IdeaQuery.from_idea()
      |> IdeaFilter.query(filter)
      |> Pagination.query(pagination)
      |> IdeaOrder.query(order)
      |> IdeaQuery.preload_assocs()
      |> Repo.all()
      |> Enum.map(&Idea.populate_cover_url/1)
    else
      _invalid_changeset ->
        {:error,
         %{
           pagination: pagination_changeset,
           filter: filter_changeset,
           order: order_changeset
         }}
    end
  end

  @impl true
  def get_ideas_count(params \\ %{}) do
    filter = struct(IdeaFilter, params[:filter] || params["filter"] || %{})

    IdeaQuery.from_idea()
    |> IdeaFilter.query(filter)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def toggle_idea_like!(idea, user) do
    query =
      LikeQuery.from_like()
      |> LikeQuery.where_idea_id(idea.id)
      |> LikeQuery.where_user_id(user.id)

    if Repo.exists?(query) do
      Repo.delete_all(query)
    else
      Repo.insert!(%Like{
        idea_id: idea.id,
        user_id: user.id
      })
    end

    :ok
  end

  @impl true
  def is_liked?(idea, user) do
    query =
      LikeQuery.from_like()
      |> LikeQuery.where_idea_id(idea.id)
      |> LikeQuery.where_user_id(user.id)

    Repo.exists?(query)
  end

  @impl true
  def get_likes(user) do
    LikeQuery.from_like()
    |> LikeQuery.where_user_id(user.id)
    |> Repo.all()
  end

  @impl true
  def paginate_ideas(params \\ %{}) do
    filter_changeset = IdeaFilter.changeset(%IdeaFilter{}, params[:filter] || params["filter"] || %{})
    pagination_changeset = Pagination.changeset(%Pagination{}, params[:pagination] || params["pagination"] || %{})
    order_changeset = IdeaOrder.changeset(%IdeaOrder{}, params[:order] || params["order"] || %{})

    with %Changeset{valid?: true} <- filter_changeset,
         %Changeset{valid?: true} <- pagination_changeset,
         %Changeset{valid?: true} <- order_changeset do
      filter = Changeset.apply_changes(filter_changeset)
      order = Changeset.apply_changes(order_changeset)
      pagination = Changeset.apply_changes(pagination_changeset)

      page =
        IdeaQuery.from_idea()
        |> IdeaQuery.join_category()
        |> IdeaFilter.query(filter)
        |> IdeaOrder.query(order)
        |> IdeaQuery.preload_assocs()
        |> Repo.scrivener_paginate(pagination)

      entries =
        page.entries
        |> Enum.map(&Idea.populate_cover_url/1)

      {:ok,
       %{
         pagination: pagination,
         filter: filter,
         order: order,
         entries: entries,
         total_pages: page.total_pages,
         total_entries: page.total_entries
       }}
    else
      _invalid_changeset ->
        {:error,
         %{
           pagination: pagination_changeset,
           filter: filter_changeset,
           order: order_changeset
         }}
    end
  end

  def change_idea(idea) do
    Idea.changeset(idea, %{})
  end

  @impl true
  def create_idea(params) do
    %Idea{}
    |> Idea.changeset(params)
    |> Repo.insert()
  end

  @impl true
  def update_idea(idea, params) do
    idea
    |> Idea.changeset(params)
    |> Repo.update()
  end

  @impl true
  def delete_idea(idea) do
    idea
    |> Repo.delete()
  end

  @impl true
  def get_category(id) do
    Repo.get(Category, id)
  end

  @impl true
  def get_categories do
    Category
    |> Repo.all()
  end

  def paginate_categories(params \\ %{}) do
    pagination_changeset = Pagination.changeset(%Pagination{}, params[:pagination] || params["pagination"] || %{})
    order_changeset = CategoryOrder.changeset(%CategoryOrder{}, params[:order] || params["order"] || %{})

    with %Changeset{valid?: true} <- pagination_changeset,
         %Changeset{valid?: true} <- order_changeset do
      order = Changeset.apply_changes(order_changeset)
      pagination = Changeset.apply_changes(pagination_changeset)

      page =
        CategoryQuery.from_category()
        |> CategoryOrder.query(order)
        |> Repo.scrivener_paginate(pagination)

      {:ok,
       %{
         pagination: pagination,
         order: order,
         entries: page.entries,
         total_pages: page.total_pages,
         total_entries: page.total_entries
       }}
    else
      _invalid_changeset ->
        {:error,
         %{
           pagination: pagination_changeset,
           order: order_changeset
         }}
    end
  end

  def change_category(category) do
    Category.changeset(category, %{})
  end

  @impl true
  def create_category(params) do
    %Category{}
    |> Category.changeset(params)
    |> Repo.insert()
  end

  @impl true
  def update_category(category, params) do
    category
    |> Category.changeset(params)
    |> Repo.update()
  end

  @impl true
  def delete_category(category) do
    category
    |> Repo.delete()
  end
end
