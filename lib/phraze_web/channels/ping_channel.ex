defmodule PhrazeWeb.PingChannel do
  use Phoenix.Channel

  def join(_topic, _packet, socket) do
    {:ok, socket}
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  #def join("room:lobby", _message, socket) do
  #  {:ok, socket}
  #end

  #def join("room:" <> _private_room_id, _params, _socket) do
  #  {:error, %{reason: "unauthorized"}}
  #end

  #def handle_in("new_msg", %{"body" => body}, socket) do
  #  broadcast!(socket, "new_msg", %{body: body})
  #  {:noreply, socket}
  #end
end
