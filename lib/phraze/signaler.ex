defmodule Phraze.Signaler do

  @moduledoc """
  Signaler for listening to websocket connections and handling messages
  """
  @behaviour :cowboy_websocket

  require Logger

  def init(request, _state) do
    state = %{registry_key: request.path}

    IO.puts("Signaler init #{self()}")
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.Phraze
    |> Registry.register(state.registry_key, {})
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    IO.puts("received message: #{message}")
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

 # First
  def handle_msg(message, state) do

    action = get_action(message)
    case action do
      "join" ->
        Logger.info("Find out the type of user that is connecting")
      _ ->
        "unknown action #{action}"
    end


    # This needs to be moved to patron and interpreter queue registries instead
    Registry.Phraze
    |> Registry.dispatch(

      state.registry_key, fn(entries) ->

        Logger.info("Typeof entries: #{typeof(entries)}")
        IO.inspect(entries)
        for {pid, _} <- entries do
          if pid != self() do
            send_to(message, pid)
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

  defp get_action(msg) do
    Jason.decode!(msg, keys: :atoms)
    |> Map.get(:action)
  end

  defp send_to(payload, pid) do
    IO.puts("Sending #{payload.action} to #{inspect(pid)} from #{inspect(self())}")
    action = payload.action
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
        Process.send(pid, Jason.encode(payload), [])
      "ice_candidate" ->
        Process.send(pid, Jason.encode(payload), [])
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
