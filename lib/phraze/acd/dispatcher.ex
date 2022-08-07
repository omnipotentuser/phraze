defmodule Phraze.Acd.Dispatcher do
  @moduledoc """
  The ACD Dispatcher acts as an interface between the Signaler and the
  registrars and queues for clients that join and make call requests. The
  Dispatcher is responsible placing Socket PIDs that gets created from the
  cowboy_websocket into the appropriate queue or registrar for preserving the
  connection and its state.

  The Dispatcher does not carry any state so a genserver is not needed.

  Once a client enters a session, a session that has call request of a peer to
  peer, a pstn telephony, SFU media room or a MCU conference, the pid from
  target queue is dispatched to the session process to be handled further.

  After the session is completed, the user agent pid, depending on type of user,
  returns to the queue or the user agent registrar as defined in the ACD
  Dispatcher. This action may be programmatically executed, or performed through
  the end user triggering action as brokered by the Signaler to the ACD
  Dispatcher.
  """


  require Logger

  alias Phraze.Acd.{Registrar, Vri}
  alias Phraze.{SessionSupervisor, SessionRunner}


  # Signaler calls this to send out the call type for the acd to handle. The
  # handler here then begins the process assigning the socket pid and other
  # attributes carried as a parameter to be stored into the appropriate module
  # for the module to take action. A chain of effects may be performed and
  # returned to the Signaler with an updated state and action telling the
  # Signaler what to do next.
  #
  # i.e. after the Dispatcher and other modules processes the request, the
  # return may carry the pid of the caller or of all belonging to the room to
  # notify of a message or action.
  #
  # type: type of call request - register_patron, vri_patron, vrs_patron,
  # vri_agent, vrs_agent uuid: the user id of user agent (UA) created by the end
  # user application device: the device of the end user if exists. may be empty.
  def handle_request(pid, payload) do
    action = get_action(payload)

    # possible actions:
    # "join", assumed to be for patrons to register themselves
    # "vri_call", patrons making a vri call request
    # "vri_terp_join", interpreter joining and going to vri queue
    # "sdp", negotiation by the offer and answer UA
    # "ice_candidate", peers exchanging their ice_ca
    case action do
      "join" ->
        Logger.info("Sending its way to the Patron Registrar by connecting via a named channel")
        route_to(:registrar_add, %{pid: pid, payload: payload})

      "peer_to_peer" ->
        route_to(:peer_to_peer, %{pid: pid, payload: payload})
      "vri_call" ->
        Logger.info("Sending its way to the ACD dispatcher to begin VRI call session.")
        route_to(:vri_call, pid, payload)
      "vri_terp_join" ->
        Logger.info("Sending its way to the vri dispatcher for agent to enter VRI queue.")
        route_to(:vri_terp_join, pid, payload)
      "sdp" ->
        Logger.info("Sending its way to Session Controller for SDP negotiation")
        route_to(:sdp, pid, payload)
      "ice_candidate" ->
        Logger.info("Sending its way to Session Controller for ICE Candidate forwarding")
        route_to(:ice_candidate, pid, payload)
      _ ->
        "unknown action #{action}"
    end
  end


  # when a peer connects they register by adding themselves to the Registry. A
  #
  defp route_to(:registrar_add, args) do
    Logger.info("ACD Dispatcher create new vri patron acd process from ACD module")
    Registrar.UserAgent.add(args)
    {:ok}
  end

  defp route_to(:peer_to_peer, args) do

    # adds a new supervisor to the Application Supervisor
    DynamicSupervisor.start_child(SessionRunner, {SessionSupervisor, args})
    # creates a SessionSupervisor Supervisor
  end

  # patron sends a message to start a vri call
  defp route_to(:vri_call,_agent_pid, _payload) do
    Logger.info("ACD Dispatcher create new vri patron acd process from ACD module")
    # Vri.Patron.add_to_waiting(pid, payload)
    # {:ok, agent_pid} = Vri.Agent.GetFirst()

  end

  # May want to test this using FunWithFlags when I am ready to add device
  # information to use for records
  defp route_to(:vri_terp_join, _pid, _payload) do
    Logger.info("ACD Dispatcher create new vri patron acd process from ACD module")

    {:ok}
  end

  # May want to test this using FunWithFlags when I am ready to add type
  # for routing
  defp route_to(:sdp, _ua_pid, _payload) do
    Logger.info("ACD Dispatcher passes the sdp to the peers")
    # Session.Controller.sdp(ua_pid, channel, payload)
    {:ok}
  end

  defp route_to(:ice_candidate, _ua_pid, _payload) do
    Logger.info("ACD Dispatcher passes the ice candidates to the peers")
    # Session.Controller.ice_candidate(pid, channel, payload)
    {:ok}
  end

  # Signaler calls the routing function and if the Dispatcher determines the UA
  # to be a UA registering, this function gets called to send the pid to the
  # patron module to be registered.

  # For now, Signaler does not have rule to probe
  # if UA is registering. The behavior allows for an immediate vri callrequest,
  # so in the future we will get to this point
  #
  # Once this is implemented, this will get the pid assigned to patron registry
  # module
  defp register_ua(%{pid: _pid, uuid: _uuid, device: _device}) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
    {:ok}
  end


  defp get_action(msg) do
    Jason.decode!(msg, keys: :atoms)
    |> Map.get(:action)
  end
end
