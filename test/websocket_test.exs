defmodule WebsocketTest do
  @moduledoc """
    Websocket Test
  """

  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  alias Phraze.TestWebsocketClient, as: TestClient

  setup do
    url = "ws://localhost:1337/ws/signaler"
    {:ok, pidA} = TestClient.start_link(url, [])
    {:ok, pidB} = TestClient.start_link(url, [])
    [pidA: pidA, pidB: pidB, url: url]
  end

  describe "handle_cast callback" do
    # test "is called", context do
    #   WebSockex.send_frame(context.pid, {:pid_reply})

    #   assert_receive :cast
    # end

    # test "can reply with a message", context do
    #   message = :erlang.term_to_binary(:cast_msg)
    #   TestClient.cast(context.pid, {:send, {:binary, message}})

    #   assert_receive :cast_msg
    # end

    test "send ping and receive pong", context do
      WebSockex.send_frame(context.pidA, {:text, "ping"})
      assert_receive "pong"
    end
  end

  # test "websockex connection returns a new PID" do
  #   {:ok, pid} = WebSockex.start("ws://localhost:1337/ws/signaler", __MODULE__, [])
  #   [{_, type} | _] = IEx.Info.info(pid)
  #   assert type == "PID"
  #   IO.puts("websockex pid #{inspect(pid)}")
  #   assert is_pid(pid) == true
  # end

  # test "websockex send ping receive pong" do
  #   client_a = WebSockex.start("ws://localhost:1337/ws/signaler", __MODULE__, [])
  #   def handle_frame({:text, msg}, state) do
  #     assert "pong" == msg
  #     {:ok, state}
  #   end
  #   WebSocket.send_frame(client_a, "ping")
  # end

end
