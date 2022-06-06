defmodule WebsocketUtilsTest do
  @moduledoc """
    Websocket Test Utilties set up to support the integration of the cowboy websocket server
  """

  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  import Phraze.Signaler

  test "ping" do
    assert {:ok, "pong"} = handle_msg("ping")
  end
end
