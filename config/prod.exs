# Do not print debug messages in production
config :logger, level: :info

config :phraze, Phraze.Repo,
  hostname: System.get_env("DATABASE_HOSTNAME"),
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  pool_size: System.get_env("DATABASE_POOL_SIZE") || 10,
  database: System.get_env("DATABASE_NAME"),
  url: System.get_env("DATABASE_URL")
