defmodule PhrazeWeb.PageControllerTest do
  use PhrazeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "<html><body>You are being <a href=\"/room/new\">redirected</a>.</body></html>"
  end
end
