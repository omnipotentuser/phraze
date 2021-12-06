defmodule Phraze.Repo do
  use Ecto.Repo,
    otp_app: :phraze,
    adapter: Ecto.Adapters.Postgres
end
