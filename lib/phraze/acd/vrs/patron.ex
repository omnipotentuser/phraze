defmodule Phraze.Acd.Vrs.Patron do
  @moduledoc """
  A waiting room for the Patron to stay at until next vrs interpreter agent is
  available to take the request
  """
  use GenServer

  def start_link(_) do
    IO.puts("Starting ACD Controller")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end


  # Create new ACD for patrons to wait in a queue
  #
  # NICK - need to create a :continue to allow the controller to spawn multiple acds
  def create_acd(:vri_patron) do
    IO.puts("ACD Controller create new vri patron acd process from ACD module")
    #GenServer.cast(__MODULE__, {:put, key})
    {:ok}
  end

  # Create new ACD for interpreters to wait for the next session
  def create_acd(:vri_interpreter) do
    IO.puts("ACD Controller create new vri interpreter acd process from ACD module")
    #GenServer.cast(__MODULE__, {:put, key})
    {:ok}
  end

  # Do not need to use call, we want async
  # def get (key) do
  #   GenServer.call(__MODULE__, {:put, key})
  # end

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
    IO.puts "gets called after init"
    {:noreply, state}
  end

end
