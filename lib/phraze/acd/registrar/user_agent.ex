defmodule Phraze.Acd.Registrar.UserAgent do
  @moduledoc """
  Patron socket pid gets added to the User Agent registry. The patron then becomes
  available for creating new call requests or receive calls.

  A Registry needs to be added to Applications Supervisor and linked. If the pid
  crashes then the socket has to reconnect and be added back to the new registry
  pid.

  An User Agent may register to multiple channels just like IRC. The agent can get updated with
  status of its state
  """

  require Logger
  @agent_available :available
  # @agent_away :away
  # @agent_busy :busy

  defstruct status: @agent_available

  # var payload = {
  #  action: "join",
  #  extension: extension,
  #  myUserId: myUserId
  # }
  def add(%{pid: _pid, payload: payload}) do
    Logger.info("Add a new User Agent to the PeerRegistrar")
    # parsed_payload = Jason.decode!(payload, [keys: :atoms])
    digest = Map.merge(payload, %{status: @agent_available})

    # returns new Register pid
    Registry.register(Phraze.PeerRegistrar, digest.extension, digest)
  end

  def remove(%{extension: _extension, my_user_id: _my_user_id, pid: _pid}) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
    # GenServer.cast(__MODULE__, {:put, key})a sessi
    {:ok}
  end

  def update_status(:busy, %{extension: _extension, my_user_id: _my_user_id, pid: _pid}) do
    IO.puts("Updates the agent status to busy")
    # GenServer.cast(__MODULE__, {:put, key})a sessi
    {:ok}
  end

  # def start_link(_) do
  #   IO.puts("Starting User Agent Registrar")
  #   GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  # end

  # def init(_) do
  #   :timer.send_after(1000, :register_db)
  #   # initialize Ecto to populate ACDs if any remains after last time the controller accessed
  #   {:ok, []}
  # end

  # get interpreter acd from Registry
  # def handle_call({:get_acd, :interpreter}, _, state) do
  #   IO.puts("handle_cast - get interpreter acd")

  #   {:reply, "", state}
  # end

  # use cast to update agent status
  # def handle_cast({:update, status}, state) do
  #   state = [ speed | state ]
  #   IO.puts("Checking state during put: #{inspect(state)}")
  #   {:noreply, state}
  # end

  # def handle_call({:clear}, _, _state) do
  #   IO.puts("handle_call clearing up batch")
  #   {:reply, "", []}
  # end

  # def handle_info(:register_db, state) do
  #   IO.puts "read and restore Registrar registry from db"
  #   {:noreply, state}
  # end
end
