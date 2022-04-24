# Do not print debug messages in production
config :logger, level: :info

config :phraze, Phraze.Repo,
  hostname: System.get_env("DATABASE_HOSTNAME"),
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  pool_size: System.get_env("DATABASE_POOL_SIZE") || 10,
  database: System.get_env("DATABASE_NAME"),
  url: System.get_env("DATABASE_URL")

config :phraze, scheme: :https

dispatch = [
  _: [
    {"/ws/signaler", Phraze.SocketHandler, []},
    {:_, Plug.Cowboy.Handler, {Phraze.Router, []}}
  ]
]

config :phraze, :cowboy,
  network_info: [
    port: 1337,
    dispatch: dispatch,
    otp_app: :phraze,
    certfile: "/etc/letsencrypt/live/bovav.com/fullchain.pem",
    keyfile: "/etc/letsencrypt/live/bovav.com/fullchain.pem"
  ]
