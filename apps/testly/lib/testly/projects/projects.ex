defmodule Testly.Projects do
  @moduledoc """
    Projects Context Public API.
  """

  defmodule Behaviour do
    alias Ecto.Changeset
    alias Testly.Projects.{Project}

    @callback get_project(String.t()) :: Project.t() | nil
    @callback get_project!(String.t()) :: Project.t()
    @callback get_relevant_project(String.t()) :: Project.t() | nil
    @callback get_projects(String.t()) :: [Project.t()]
    @callback get_projects() :: [Project.t()]
    @callback paginate_projects(map()) :: {:ok, map()} | {:error, map()}

    @callback change_project(Project.t()) :: Changeset.t()
    @callback create_project(String.t(), map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
    @callback update_project(Project.t(), map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
    @callback update_project_uploaded_script_hash(Project.t(), String.t()) :: Project.t()
    @callback delete_project(Ecto.Schema.pk()) :: :ok
  end

  @behaviour Behaviour

  import Ecto.Query, only: [limit: 2]

  alias Testly.{Repo, Pagination}
  alias Ecto.Changeset

  alias Testly.Projects.{
    Project,
    ProjectQuery,
    ProjectFilter,
    ProjectOrder
  }

  @impl true
  def get_project(id) do
    Project.from_project()
    |> Project.where_is_not_deleted()
    |> Repo.get(id)
  end

  @impl true
  def get_project!(id) do
    Project.from_project()
    |> Project.where_is_not_deleted()
    |> Repo.get!(id)
  end

  # In future this function will be more smart
  # For example, it will be returning only project on which user made his last action
  # Use case - redirect to project after user auth
  @impl true
  def get_relevant_project(user_id) do
    Project.from_project()
    |> Project.where_is_not_deleted()
    |> Project.where_user(user_id)
    |> Project.order_by_created_at_desc()
    |> limit(1)
    |> Repo.one()
  end

  @impl true
  def get_projects(user_id) do
    Project.from_project()
    |> Project.where_is_not_deleted()
    |> Project.where_user(user_id)
    |> Project.order_by_created_at_desc()
    |> Repo.all()
  end

  @impl true
  def get_projects do
    Project.from_project()
    |> Project.where_is_not_deleted()
    |> Project.order_by_created_at_desc()
    |> Repo.all()
  end

  @impl true
  def paginate_projects(params \\ %{}) do
    filter_changeset = ProjectFilter.changeset(%ProjectFilter{}, params[:filter] || params["filter"] || %{})
    pagination_changeset = Pagination.changeset(%Pagination{}, params[:pagination] || params["pagination"] || %{})
    order_changeset = ProjectOrder.changeset(%ProjectOrder{}, params[:order] || params["order"] || %{})

    with %Changeset{valid?: true} <- filter_changeset,
         %Changeset{valid?: true} <- pagination_changeset,
         %Changeset{valid?: true} <- order_changeset do
      filter = Changeset.apply_changes(filter_changeset)
      order = Changeset.apply_changes(order_changeset)
      pagination = Changeset.apply_changes(pagination_changeset)

      page =
        ProjectQuery.from_project()
        |> Project.where_is_not_deleted()
        |> ProjectFilter.query(filter)
        |> ProjectOrder.query(order)
        |> Repo.scrivener_paginate(pagination)

      {:ok,
       %{
         pagination: pagination,
         filter: filter,
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
           filter: filter_changeset,
           order: order_changeset
         }}
    end
  end

  @impl true
  def change_project(%Project{} = project) do
    Changeset.change(project)
  end

  @impl true
  def create_project(user_id, params) do
    %Project{user_id: user_id}
    |> Project.create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def update_project(project, params) do
    project
    |> Project.update_changeset(params)
    |> Repo.update()
  end

  @impl true
  def update_project_uploaded_script_hash(project, hash) do
    project
    |> Changeset.change(%{uploaded_script_hash: hash})
    |> Repo.update!()
  end

  @impl true
  def delete_project(project) do
    project
    |> Changeset.change(%{is_deleted: true})
    |> Repo.update!()

    :ok
  end
end
