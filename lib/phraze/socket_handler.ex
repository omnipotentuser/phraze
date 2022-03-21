defmodule Phraze.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}

    IO.puts("init #{state.registry_key}")
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.Phraze
    |> IO.inspect()
    |> Registry.register(state.registry_key, {})
    IO.inspect(self())
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    payload = Jason.decode!(message)
    action = payload["action"]

    IO.puts("Action received: #{action} from")
    IO.inspect(self())

    Registry.Phraze
    |> Registry.dispatch(state.registry_key, fn(entries) ->
      for {pid, _} <- entries do

        if pid != self() do

          IO.puts("Sending #{action} to")
          IO.inspect(pid)

          # If there exists a pid that is some other value then
          # send the other pids other than self() to create an offer
          case action do
            "join" ->
              # Ideally, in the future we keep track of rooms and the uuid
              # assigned to the room. The room can be an extension number or a conference
              # call, or simply a readable room name.
              uuid = payload["fromUserId"]
              {:ok, offer} = Jason.encode( %{
                type: "create_offer",
                fromUserId: uuid
              })
              Process.send(pid, offer, [])
            "sdp" ->
              Process.send(pid, message, [])
            "ice_candidate" ->
              Process.send(pid, message, [])
            #_ ->
            #  "Unknown action #{action}"
          end
        end
      end
    end)

    {:reply, {:text, "ok"}, state}
  end

  def websocket_info(info, state) do
    IO.puts("websocket_info #{info}")
    {:reply, {:text, info}, IO.inspect(state)}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    :ok
  end
end
