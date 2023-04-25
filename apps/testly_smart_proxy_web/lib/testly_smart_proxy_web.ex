defmodule TestlySmartProxyWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TestlySmartProxyWeb, :controller
      use TestlySmartProxyWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TestlySmartProxyWeb
      import Plug.Conn
      import TestlySmartProxyWeb.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/testly_smart_proxy_web/templates",
                        namespace: TestlySmartProxyWeb

      import TestlySmartProxyWeb.Router.Helpers
      import TestlySmartProxyWeb.ErrorHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
