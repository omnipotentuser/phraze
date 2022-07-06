defmodule WebsocketTest do
  @moduledoc """
    Websocket Test
  """

  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  alias Phraze.TestWebsocketClient, as: TestClient

  @wait_period 20

  setup do
    url = "ws://localhost:1337/ws/signaler"
    {:ok, pid_a} = TestClient.start_link(url, [])
    # [pid_a: pid_a, url: url]
    {:ok, pid_b} = TestClient.start_link(url, [])
    [pid_a: pid_a, pid_b: pid_b, url: url]
  end

  describe "handle_cast callback" do

    test "send ping and receive pong", context do

      assert :ok = TestClient.send_client(context.pid_a, "ping")
      Process.sleep @wait_period
      msg = TestClient.get_state(context.pid_a)
      assert ["pong"] = msg

    end

    test "send sdp", context do

      rand_num = :rand.uniform(1000)
      payload = %{
        action: "sdp",
        fromUserId: rand_num,
        description: "m=video 9 UDP/TLS/RTP/SAVPF 96 125 97 126"
      }
      assert :ok = TestClient.send_client(context.pid_a, Jason.encode!(payload))
      Process.sleep @wait_period
      msg = TestClient.get_state(context.pid_b)
      assert [payload] == msg
    end

    test "send ice_candidates", context do
      1..10
      |> Enum.map(fn x ->
        rand_num = :rand.uniform(1000)
          payload = %{
            action: "ice_candidate",
            fromUserId: rand_num,
            description: "a=candidate:4234997325 #{x} udp 2043278322 192.168.0.56 44323 typ host"
          }

          assert :ok = TestClient.send_client(context.pid_a, Jason.encode!(payload))
          Process.sleep @wait_period
          msg = TestClient.get_state(context.pid_b)
          assert [payload] == msg
      end)
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
