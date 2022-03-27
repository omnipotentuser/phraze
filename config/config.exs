# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phraze,
  ecto_repos: [Phraze.Repo],
  url: System.get_env("DATABASE_URL")

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :phraze, Phraze.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Fun With Flags with built in Phoenix PubSub
# config :fun_with_flags, :cache_bust_notifications,
#  [enabled: true, adapter: FunWithFlags.Notifications.PubSub, client: Phraze.PubSub]

# config :fun_with_flags, :redis,
#  host: "localhost",
#  port: 6379,
#  database: 0

config :fun_with_flags, :cache_bust_notifications, [enabled: false]

# FunWithFlags configuration.
config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: MyApp.Repo
  # Default table name is "fun_with_flags_toggles".

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
