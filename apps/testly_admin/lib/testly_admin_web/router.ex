defmodule TestlyAdminWeb.Router do
  use TestlyAdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug(Testly.Authenticator.InvalidateSessionPlug)
    plug(Testly.Authenticator.FetchUserPlug)
  end

  pipeline :ensure_auth do
    plug(TestlyAdminWeb.EnsureAuthenticated)
  end

  scope "/auth", TestlyAdminWeb do
    pipe_through :browser

    get "/signin", SessionController, :new
    post "/signin", SessionController, :create
    delete "/signout", SessionController, :delete
  end

  get("/health", TestlyAdminWeb.HealthController, :index)

  scope "/", TestlyAdminWeb do
    pipe_through([:browser, :ensure_auth])

    get("/", PageController, :index)
    resources("/projects", ProjectController)
    resources("/users", UserController)
    resources("/test_ideas", TestIdeaController)
    resources("/test_idea_categories", TestIdeaCategoryController)

    post("/users/:user_id/sign_in", UserController, :sign_in)
  end
end
