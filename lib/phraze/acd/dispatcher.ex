defmodule Phraze.Acd.Dispatcher do
  @moduledoc """
  The ACD Dispatcher acts as a layer between the Signaler and the registrars and queues for
  clients that join and make call requests. The Dispatcher is responsible placing
  Socket PIDs that gets created from the cowboy_websocket into the appropriate
  queue or registry for preserving the connection and its state.

  The Dispatcher does not carry any state so a genserver is not needed.

  Once a client enters a session, a session that has call request of a peer to
  peer, a pstn telephony, SFU media room or a MCU conference, the pid from
  target queue is dispatched to the session process to be handled further.

  After the session is completed, the user agent pid, depending on type of user,
  returns to the queue or the user agent registry as defined in the ACD Dispatcher.
  This action may be programmatically executed, or performed through the end
  user triggering action as brokered by the Signaler to the ACD Dispatcher.
  """


  require Logger

  alias Phraze.Acd.{Registrar, Vri}


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
        #var payload = {
        #  action: "join",
        #  channel: channel,
        #  fromUserId: myUserId
        #}
        route_to(:register, pid, payload)

      "vri_call" ->
        Logger.info("Sending its way to the ACD dispatcher to begin VRI call session.")
        route_to(:vri_call, pid, payload)
      "vri_terp_join" ->
        Logger.info("Sending its way to the vri dispatcher for agent to enter VRI queue.")
        route_to(:vri_terp_join, pid, payload)
      "sdp" ->
        Logger.info("Sending its way to Session Controller for SDP negotiation")
      "ice_candidate" ->
        Logger.info("Sending its way to Session Controller for ICE Candidate forwarding")
      _ ->
        "unknown action #{action}"
    end
  end


  def route_to(:register, pid, payload) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
    Registrar.UserAgent.register(pid, uuid, payload)
    {:ok}
  end

  def route_to(:vri_call, pid, payload) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
    Vri.UserAgent.
    {:ok}
  end

  # May want to test this using FunWithFlags when I am ready to add device
  # information to use for records
  def route_to(pid, payload, _device) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")

    {:ok}
  end

  # May want to test this using FunWithFlags when I am ready to add type
  # for routing
  def route_to(pid, uuid, payload, _device, _type) do
    IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")

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
