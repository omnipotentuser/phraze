defmodule Phraze.ReleaseTasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:phraze)

    path = Application.app_dir(:phraze, "priv/repo/migrations")

    Ecto.Migrator.run(Phraze.Repo, path, :up, all: true)
  end
end
