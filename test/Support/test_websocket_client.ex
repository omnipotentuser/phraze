defmodule Phraze.TestWebsocketClient do
  use WebSockex

  def start_link(url, state) do
    WebSockex.start_link(url, __MODULE__, state)
  end

  def send_client(pid, message) do
    WebSockex.send_frame(pid, {:text, message})
  end

  def get_state(pid) do
    :ok = WebSockex.cast(pid, {:get_state, self()})

    receive do
      msg -> msg
    after
      200 -> raise "State didn't return after 200ms"
    end
  end

  def handle_cast({:get_state, pid}, state) do
    IO.puts ("handle_cast #{inspect state}")
    #item = hd(state)
    send(pid, state)
    {:ok, tl(state)}
  end

  def handle_frame({:text, "ok" = msg}, state) do
    IO.puts "handle_frame #{inspect msg}, state - #{inspect state}"
    {:ok, state}
  end

  def handle_frame({:text, "pong" = msg}, state) do
    IO.puts "Received Pong - Message: #{inspect msg}, state - #{inspect state}"
    state = state ++ [msg]
    IO.puts("handle_frame -pong- #{inspect state}")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) when is_bitstring(msg) do
    IO.puts "Received text - Message: #{inspect msg}, state - #{inspect state}"
    {:ok, payload} = Jason.decode(msg, keys: :atoms)
    state = state ++ [payload]
    IO.puts("handle_frame negotiate #{inspect state}")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    IO.puts "Catch-All: Received Message - #{inspect msg}, state - #{inspect state}"
    {:close, state}
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect reason}\n\n#{inspect state}\n")
    exit(:normal)
  end

  #defp examine_packet(%{action: sdp, description: desc, fromUserId: userid}), do: {:ok, %{action: sdp, description: desc, fromUserId: userid}}
  #defp examine_packet(_), do: {:error, %{}}
end
