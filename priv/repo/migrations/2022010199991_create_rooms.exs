defmodule Phraze.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table("rooms") do
      add :slug, :string
      add :title, :string
      add :active_call, :boolean, default: false

      timestamps()
    end

    create unique_index(:rooms, :slug)
  end
end
