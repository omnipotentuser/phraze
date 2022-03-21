defmodule PhrazeWeb.PageController do
  use PhrazeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def webclient(conn, _params) do
    render(conn, "webclient.html")
  end
end
