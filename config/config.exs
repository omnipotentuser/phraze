# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phraze,
  ecto_repos: [Phraze.Repo]

# Configures the endpoint
config :phraze, PhrazeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fp8vy7IP0K3FYESAvQTbkNK9+FkBAHhPoiWso1XRd9+pyZKgoLeEesChNKl7l+wR",
  render_errors: [view: PhrazeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Phraze.PubSub,
  live_view: [signing_salt: "UCw7g1fH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
