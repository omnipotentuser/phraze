defmodule Phraze.Acd.CallRouter do
  @moduledoc """
  The ACD Router acts as a layer between the Signaler and the call queues for
  clients that join and make call requests. The Router is responsible placing
  Socket PIDs that gets created from the cowboy_websocket into the appropriate
  queue or registry for preserving the connection and its state.

  The Router is supervised by the Application Supervisor.

  Once a client enters a session, a session that has call request of a peer to
  peer, a pstn telephony, SFU media room or a MCU conference, the pid from
  target queue is dispatched to the session process to be handled further.

  After the session is completed, the user agent pid, depending on type of user,
  returns to the queue or the user agent registry as defined in the ACD Router.
  This action may be programmatically executed, or performed through the end
  user triggering action as brokered by the Signaler to the ACD Router.
  """
  use GenServer

  def start_link(_) do
    IO.puts("Starting ACD Router")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Signaler calls this to send out the call type for the acd to handle. The
  # handler here then begins the process assigning the socket pid and other
  # attributes carried as a parameter to be stored into the appropriate module
  # for the module to take action. A chain of effects may be performed and
  # returned to the Signaler with an updated state and action telling the
  # Signaler what to do next.
  #
  # i.e. after the router and other modules processes the request, the
  # return may carry the pid of the caller or of all belonging to the room to
  # notify of a message or action.
  #
  # type: type of call request - register_patron, vri_patron, vrs_patron,
  # vri_agent, vrs_agent uuid: the user id of user agent (UA) created by the end
  # user application device: the device of the end user if exists. may be empty.
  def handle_request(%{pid: _pid, type: _type, uuid: _uuid, device: _device}) do
    IO.puts("ACD Router create new vri patron acd process from ACD module")
    #GenServer.cast(__MODULE__, {:put, key})a sessi
    {:ok}
  end

  def init(_) do
    :timer.send_after(1000, :mock_db)
    # initialize Ecto to populate ACDs if any remains after last time the Router accessed
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

  # Signaler calls the routing function and if the router determines the UA
  # to be a UA registering, this function gets called to send the pid to the
  # patron module to be registered.

  # For now, Signaler does not have rule to probe
  # if UA is registering. The behavior allows for an immediate vri callrequest,
  # so in the future we will get to this point
  #
  # Once this is implemented, this will get the pid assigned to patron registry
  # module
  defp register_ua(%{pid: _pid, uuid: _uuid, device: _device}) do
    IO.puts("ACD Router create new vri patron acd process from ACD module")
    #GenServer.cast(__MODULE__, {:put, key})a sessi
    {:ok}
  end
end
