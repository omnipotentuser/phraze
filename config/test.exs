import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :phraze, Phraze.Repo,
  hostname: System.get_env("DATABASE_HOSTNAME"),
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  database: System.get_env("DATABASE_NAME"),
  # database: "phraze_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# In test we don't send emails.
config :phraze, Phraze.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :phraze, scheme: :http

dispatch = [
  _: [
    {"/ws/signaler", Phraze.Signaler, []},
    {:_, Plug.Cowboy.Handler, {Phraze.Router, []}}
  ]
]

config :phraze, :cowboy,
  network_info: [
    port: 1337,
    dispatch: dispatch
  ]
