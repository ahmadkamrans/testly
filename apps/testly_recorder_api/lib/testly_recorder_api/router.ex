defmodule TestlyRecorderAPI.Router do
  use TestlyRecorderAPI, :router
  use Honeybadger.Plug

  pipeline :api do
    plug(:accepts, ["json", "js"])
    plug(ProperCase.Plug.SnakeCaseParams)
  end

  get("/health", TestlyRecorderAPI.HealthController, :index)

  scope "/", TestlyRecorderAPI do
    pipe_through(:api)
    # https://developer.mozilla.org/en-US/docs/Web/API/Beacon_API
    post("/track/:session_recording_id", RecorderController, :track_session_recording)
    get("/split_test_settings", RecorderController, :split_test_settings)
    get("/script/:project_id", RecorderController, :script)
    post("/feedback/poll/:poll_id/respond", FeedbackController, :respond_to_poll)
    post("/feedback/response/:response_id/add_answer", FeedbackController, :add_answer_to_response)
  end
end
