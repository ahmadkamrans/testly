defmodule TestlyAPI.Router do
  use TestlyAPI, :router
  import Phoenix.LiveDashboard.Router

  pipeline :auth do
    plug(Testly.Authenticator.InvalidateSessionPlug)
    plug(Testly.Authenticator.FetchUserPlug)
    plug(TestlyAPI.Plug.AuthContext)
  end

  pipeline :ensure_admin do
    plug TestlyAPI.EnsureAdmin
  end

  pipeline :api do
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
    # NOTE: it is very important that is accepts only json,
    # it will protect us from CSRF
    # But it still can be attacked via flash - https://security.stackexchange.com/questions/170477/csrf-with-json-post-when-content-type-must-be-application-json
    # And we are not protected if browser doesn't support CORS
    plug(:accepts, ["json"])
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
  end

  get("/health", TestlyAPI.HealthController, :index)

  scope "/" do
    pipe_through([:api, :auth])

    forward(
      "/graphql",
      Absinthe.Plug,
      schema: TestlyAPI.Schema,
      json_codec: Jason
    )

    resources("/sessions", TestlyAPI.SessionController, only: [:delete], singleton: true)
  end

  scope "/" do
    pipe_through([:browser, :auth, :ensure_admin])

    live_dashboard "/dashboard", metrics: TestlyAPI.Telemetry
  end

  scope "/" do
    pipe_through([:browser, :auth])

    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: TestlyAPI.Schema,
      interface: :playground
    )
  end
end
