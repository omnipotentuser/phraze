defmodule PhrazeWeb.PageController do
  use PhrazeWeb, :controller

  def index(conn, _params) do
    # NICK - If we want to render plain index
    # render(conn, "index.html")
    conn
    |> redirect(to: Routes.room_new_path(conn, :new))
  end
end
