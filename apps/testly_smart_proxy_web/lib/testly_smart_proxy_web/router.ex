defmodule TestlySmartProxyWeb.Router do
  use TestlySmartProxyWeb, :router

  get("/", TestlySmartProxyWeb.ProxyController, :root)

  get("/health", TestlySmartProxyWeb.HealthController, :index)

  get "/proxy/:recording_id/:url", TestlySmartProxyWeb.ProxyController, :index
end
