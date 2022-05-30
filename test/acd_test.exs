defmodule AcdTest do
  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  alias Phraze.AcdController, as: AcdController

  test "start with :sock and check if return type == PID" do
    {:ok, pid} = AcdController.start_link({:sock, "pid1"})
    [{_, type} | _] = IEx.Info.info(pid)
    assert type == "PID"
  end

  test "create patron ACD process" do
    retval = AcdController.create_acd(:vri_patron)
    assert {:ok} == retval
  end

  test "create interpreter ACD process" do
    retval = AcdController.create_acd(:vri_interpreter)
    assert {:ok} == retval
  end
end
