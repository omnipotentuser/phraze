defmodule Phraze.Organizer do
  alias Phraze.Repo
  alias Phraze.Room

  import Ecto.Query

  def get_room(slug) when is_binary(slug) do
    from(room in Room, where: room.slug == ^slug)
    |> Repo.one()
  end
end
