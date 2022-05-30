defmodule WebsocketTest do
  @moduledoc """
    Websocket Test
  """

  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  alias Phraze.TestWebsocketClient, as: Wsclient

  # alias Phraze.Signaler, as: Signaler
  import Phraze.Signaler

  test "ping" do
    assert {:ok, "pong"} = handle_msg("ping")
  end

  test "websockex connection returns a new PID" do
    {:ok, pid} = WebSockex.start("ws://localhost:1337/ws/signaler", __MODULE__, [])
    [{_, type} | _] = IEx.Info.info(pid)
    assert type == "PID"
    IO.puts("websockex pid #{inspect(pid)}")
    assert is_pid(pid) == true
  end

  test "websockex send ping receive pong" do
    client_a = WebSockex.start("ws://localhost:1337/ws/signaler", __MODULE__, [])
    def handle_frame({:text, msg}, state) do
      assert "pong" == msg
      {:ok, state}
    end
    WebSocket.send_frame(client_a, "ping")

  end

  # 4) Use the "test" macro instead of "def" for clarity.
  test "the truth" do
    assert 2 = 1 + 1
  end

end
