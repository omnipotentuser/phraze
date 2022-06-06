defmodule Phraze.Signaler do

  @moduledoc """
  Signaler for listening to websocket connections and handling messages
  """
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}

    IO.puts("init #{state.registry_key}")
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    IO.inspect(state)
    IO.puts("BEFORE Registry.Phraze.............")
    Registry.Phraze
    |> IO.inspect()
    |> Registry.register(state.registry_key, {})
    IO.inspect(self())
    IO.puts("AFTER.............")
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    IO.puts("received message: #{message}")
    IO.inspect(message)
    IO.puts("typeof message: #{typeof(message)}")
    handle_msg(message, state)
    {:reply, {:text, "ok"}, state}
  end


  def handle_msg("ping" = message) do
    IO.puts("arity/1 #{message} pong")
    {:ok, "pong"}
    #Process.send(self(), "pong", [])
  end

  def handle_msg("ping" = message, _state) do
    IO.puts("#{message} pong")
    Process.send(self(), "pong", [])
  end

  def handle_msg(message, state) do
    Registry.Phraze
    |> Registry.dispatch(

      state.registry_key, fn(entries) ->

        IO.puts("Typeof entries: #{typeof(entries)}")
        IO.inspect(entries)
        for {pid, _} <- entries do
          if pid != self() do
            cmd(message, pid)
          end
        end
      end
    )
  end

  def websocket_info(info, state) do
    IO.puts("websocket_info #{info} #{inspect state}")
    {:reply, {:text, info}, IO.inspect(state)}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    :ok
  end

  def cmd(msg, pid) do
    payload = Jason.decode!(msg)
    action = payload["action"]
    IO.puts("Sending #{action} to #{inspect(pid)} from #{inspect(self())}")
    case action do
      "join" ->
        # Ideally, in the future we keep track of rooms and the uuid
        # assigned to the room. The room can be an extension number or a conference
        # call, or simply a readable room name.
        uuid = payload["fromUserId"]
        {:ok, offer} = Jason.encode(%{
          type: "create_offer",
          fromUserId: uuid
        })
        Process.send(pid, offer, [])
      "sdp" ->
        Process.send(pid, msg, [])
      "ice_candidate" ->
        Process.send(pid, msg, [])
      _ ->
        "Unknown action #{action}"
    end
  end

  defp typeof(a) do
    cond do
        is_float(a)    -> "float"
        is_number(a)   -> "number"
        is_atom(a)     -> "atom"
        is_boolean(a)  -> "boolean"
        is_binary(a)   -> "binary"
        is_function(a) -> "function"
        is_list(a)     -> "list"
        is_tuple(a)    -> "tuple"
        is_map(a)      -> "map"
        is_bitstring(a)   -> "string"
        true           -> "idunno"
    end
  end
end
