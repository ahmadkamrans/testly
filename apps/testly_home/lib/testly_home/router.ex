defmodule TestlyHome.Router do
  use TestlyHome, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(Testly.Authenticator.InvalidateSessionPlug)
    plug(Testly.Authenticator.FetchUserPlug)
  end

  pipeline :ensure_auth do
    plug(TestlyHome.EnsureAuthenticated)
  end

  get("/health", TestlyHome.HealthController, :index)

  scope "/", TestlyHome do
    # Use the default browser stack
    pipe_through([:browser])

    get("/", PageController, :index)

    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create, :delete], singleton: true)

    scope "/user", User do
      resources("/password", PasswordController,
        only: [:new, :create, :edit, :update],
        singleton: true
      )
    end

    scope "/legal" do
      get("/policy", LegalController, :policy)
      get("/terms", LegalController, :terms)
      get("/disclaimer", LegalController, :disclaimer)
      get("/agreement", LegalController, :agreement)
      get("/", LegalController, :legal)
    end

    scope "/steps", Steps do
      scope "/learn" do
        get("/session_recordings", LearnController, :session_recordings)
        get("/heatmaps", LearnController, :heatmaps)
        get("/feedback_polls", LearnController, :feedback_polls)
      end

      scope "/prove" do
        get("/ab_split_testing", ProveController, :ab_split_testing)
        get("/idea_lab", ProveController, :idea_lab)
        get("/shared_tests", ProveController, :shared_tests)
      end

      get("/grow", GrowController, :index)
    end

    get("/pricing", PricingController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/", TestlyHome do
    pipe_through([:browser, :ensure_auth])

    resources("/projects", ProjectController, only: [:new, :create])
  end

  scope "/auth", TestlyHome.ThirdPartyAuth do
    pipe_through([:browser])

    get("/facebook", FacebookAuthController, :request)
    get("/facebook/callback", FacebookAuthController, :callback)

    resources("/users", UserController, only: [:new, :create], as: :third_party_user)
  end
end
