defmodule Phraze.Acd.Registrar.UserAgent do
  @moduledoc """
  Patron socket pid gets added to the User Agent registry. The patron then becomes
  available for creating new call requests or receive calls.

  A Registry needs to be added to Applications Supervisor and linked. If the pid
  crashes then the socket has to reconnect and be added back to the new registry
  pid.

  Once a patron creates a call to vri or some other service, the dispatcher moves
  the pid of the patron to the target queue, such as VriPatron queue. If it is a
  simple p2p connection, then the dispatcher creates a new session and pulls the
  patrons into the session room and begins the negotiation.
  """
  use GenServer
  require Logger

  def register(%{pid: _pid, uuid: _uuid, device: _device}) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
    #GenServer.cast(__MODULE__, {:put, key})a sessi
    {:ok}
  end

  @doc """
  I am not sure what the initial state should look like, but for now we can have
  an empty List, and each patron that connects, a tuple consisting of :uuid,
  :name, :device, :protocol be added to the List
  """
  def start_link(_) do
    IO.puts("Starting ACD Controller")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # In the future, add a DynamicSupervisor and Registry that holds pid for each
  # Patron GenServer instead of using a List that holds tuples of the patrons.
  # This prevents the case that if the Patron pid crashes, not all patrons info
  # are lost.
  def init(_) do
    :timer.send_after(1000, :mock_db)
    # initialize Ecto to populate ACDs if any remains after last time the
    # controller accessed
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

  def handle_call({:clear}, _, _state) do
    IO.puts("handle_call clearing up batch")
    {:reply, "", []}
  end

  def handle_info(:mock_db, state) do
    IO.puts "gets called after init"
    {:noreply, state}
  end

end
