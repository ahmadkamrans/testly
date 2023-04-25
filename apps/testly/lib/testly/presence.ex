defmodule Testly.Presence do
  use Phoenix.Presence,
    otp_app: :testly,
    pubsub_server: Testly.PubSub
end
