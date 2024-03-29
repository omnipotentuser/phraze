defmodule AcdTest do
  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  alias Phraze.Acd.Vri.{InterpreterQueue, WaitQueue}

  # test "start with :sock and check if return type == PID" do
  #   {:ok, pid} = AcdController.start_link({:sock, "pid1"})
  #   [{_, type} | _] = IEx.Info.info(pid)
  #   assert type == "PID"
  # end

  test "add patron to wait queue" do
    retval = WaitQueue.add_to_queue(:patron)
    assert {:ok} == retval
  end

  test "add interpreter to queue" do
    retval = InterpreterQueue.add_to_queue(:vri_interpreter)
    assert {:ok} == retval
  end
end
