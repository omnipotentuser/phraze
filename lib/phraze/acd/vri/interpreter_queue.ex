defmodule Phraze.Acd.Vri.InterpreterQueue do
  @moduledoc """
  A queue for the interpreter agent to sit in until a request comes in to invite
  the interpreter into the vri session


  +++ Need to update +++

  the interpreter agent needs to store a new socket pid sent from the acd dispatcher
  here. Within this agent module carries a state that consists of a structure as
  defined like:

  [ %{:uuid, :gender, :max_duration_idle, :status}, ...]






  """
  use GenServer, restart: :transient
  require Logger

  @doc """
  uuid gets generated from the client, and is required
  gender defaults to none
  max_duration defaults to 2 hours, or 120 minutes
  status has ready, break, block, transfer
  ready - agent is ready to be selected
  break - agent is on a break and not accepting requests
  block - agent is being blocked processing being terminated or in a bad state, or reported to admin
  transfer - agent is being transferred to another queue or to a session
  """
  defstruct [:uuid, gender: "none", max_duration: 120, status: "ready"]

  def start_link(_) do
    IO.puts("Starting Interpreter Queue Server")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Create new ACD for patrons to wait in a queue
  #
  # NICK - need to create a :continue to allow the controller to spawn multiple acds
  def add_to_queue(:vri_interpreter) do
    IO.puts("Add interpreter to queue")
    # GenServer.cast(__MODULE__, {:put, key})
    {:ok}
  end

  def init(_) do
    :timer.send_after(1000, :mock_db)
    # initialize Ecto to populate ACDs if any remains after last time the controller accessed
    {:ok, []}
  end

  # get patron acd from Registry
  def handle_call({:get_acd, :patron}, _, state) do
    IO.puts("handle_cast - get patron acd")

    {:reply, "", state}
  end

  # get interpreter acd from Registry
  def handle_call({:get_acd, :interpreter}, _, state) do
    IO.puts("handle_cast - get interpreter acd")

    {:reply, "", state}
  end

  # def handle_cast({:put, speed}, state) when length(state) < 1024 do
  #   state = [ speed | state ]
  #   IO.puts("Checking state during put: #{inspect(state)}")
  #   {:noreply, state}
  # end

  def handle_call({:clear}, _, _state) do
    IO.puts("handle_call clearing up batch")
    {:reply, "", []}
  end

  def handle_info(:mock_db, state) do
    IO.puts("gets called after init")
    {:noreply, state}
  end
end
