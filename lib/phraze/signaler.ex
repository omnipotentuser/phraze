defmodule Phraze.Signaler do
  @moduledoc """
  Signaler for listening to websocket connections and handling messages
  """
  @behaviour :cowboy_websocket

  require Logger
  alias Phraze.Dispatcher
  alias Phraze.Utilities.Verify, as: V

  def init(request, _state) do
    state = %{registry_key: request.path}

    IO.puts("Signaler init #{inspect(self())}")
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.Phraze
    |> Registry.register(state.registry_key, {})

    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    IO.puts("received message: #{message}")
    IO.puts("typeof message: #{V.kind(message)}")
    handle_msg(message, state)
    {:reply, {:text, "ok"}, state}
  end

  def handle_msg("ping" = message) do
    IO.puts("arity/1 #{message} pong")
    {:ok, "pong"}
    # Process.send(self(), "pong", [])
  end

  def handle_msg("ping" = message, _state) do
    IO.puts("#{message} pong")
    Process.send(self(), "pong", [])
  end

  # First
  def handle_msg(message, _state) do
    # The Dispatcher will digest the message and return with list of pids
    respond = Dispatcher.handle_request(self(), message)

    # TODO - handle list of pids, not only self()
    case respond do
      {:ok, action, data} ->

        # TODO create function call to handle actions

        # Need to loop through list of agents to send to
        {:ok, respond} = Jason.encode(%{action: action, data: data})
        Process.send(self(), respond, [])

      {:error, action, reason} ->
        Process.send(self(), Jason.encode(%{error: action, reason: reason}), [])
    end

    # for each pid in the list, send the responded message to remote peer
    # websocket
    # pid_list
    # |> Enum.map(&(&1))
    # |> send_to(respond_message)

    # This needs to be moved to patron and interpreter queue registries instead
    # Registry.Phraze
    # |> Registry.dispatch(

    #   state.registry_key, fn(entries) ->

    #     Logger.info("Typeof entries: #{typeof(entries)}")
    #     IO.inspect(entries)
    #     for {pid, _} <- entries do
    #       if pid != self() do
    #         send_to(message, pid)
    #       end
    #     end
    #   end
    # )
  end

  def websocket_info(info, state) do
    IO.puts("websocket_info #{info} #{inspect(state)}")
    {:reply, {:text, info}, IO.inspect(state)}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    :ok
  end

  # defp send_to(pid, payload) do
  #   IO.puts("Sending #{payload.action} to #{inspect(pid)} from #{inspect(self())}")
  #   action = payload.action

  #   case action do
  #     "join" ->
  #       # Ideally, in the future we keep track of rooms and the uuid
  #       # assigned to the room. The room can be an extension number or a conference
  #       # call, or simply a readable room name.
  #       uuid = payload["fromUserId"]

  #       {:ok, offer} =
  #         Jason.encode(%{
  #           type: "create_offer",
  #           fromUserId: uuid
  #         })

  #       Process.send(pid, offer, [])

  #     "sdp" ->
  #       Process.send(pid, Jason.encode(payload), [])

  #     "ice_candidate" ->
  #       Process.send(pid, Jason.encode(payload), [])

  #     _ ->
  #       "Unknown action #{action}"
  #   end
  # end
end
