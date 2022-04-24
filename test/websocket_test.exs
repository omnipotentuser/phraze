defmodule WebsocketTest do
  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  import Phraze.SocketHandler

  test "ping" do
    assert {:ok, "pong"} = handle_msg("ping")
  end

  # 4) Use the "test" macro instead of "def" for clarity.
  test "the truth" do
    assert 2 = 1 + 1
  end
end
