defmodule Phraze.Presence do
  use Phoenix.Presence,
    otp_app: :phraze,
    pubsub_server: Phraze.PubSub
end
