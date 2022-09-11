defmodule Phraze.Dispatcher do
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

  alias Phraze.Acd.{Registrar}
  alias Phraze.{SessionSupervisor, SessionRunner}
  alias Phraze.Session.Controller, as: SessionController

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
  @doc """
    SEQUENCE
    1. User A sends 'call' invite to user B
    2. A new Session is created that stores the user A pid, uuid, and username.
       Session id is created.
    3. Phraze sends action 'call' to user B with payload of %{ action: 'call', session_id: integer,
    remote_peer: [%{username: String.t(), userid: String.t()}]}
    4. User B responds with accept call invite, with action 'accept' and payload
       of %{local_userid: String.t(), remote_users: [%{userid: String.t()}]}
    5. Phraze probes the payload from User B 'accept' and updates the Session of
       the User B
    6. User B sends action 'ice_config'. Phraze responds with action
       'ice_config' of the payload ice configs
    7. User B creates SDP offer to all remote peers it accepted from the call
       invite and sends sdp to Phraze with payload %{remote_userid: String.t(),
       sdp: String.t()}
    8. Phraze digests the sdp action from User B and sends to target remote
       peers the offer SDP
    9. User A and other users currently in the session gets the sdp offer.
    10. Each remote user sends ice_config action to Phraze. Same as #6.
    11. Each remote user creates SDP answer and sends Phraze. Phraze sends the
        sdp answer payload to User B.
    12. The negotiation is complete.
  """
  def handle_request(socket_pid, payload) do
    decoded_payload = Jason.decode!(payload, keys: :atoms)
    route_to(decoded_payload.action, socket_pid, decoded_payload)
  end

  # when a peer connects they register by adding themselves to the Registry.
  @spec route_to(String.t(), Pid.t(), any) :: {Atom.t(), Atom.t(), any}
  defp route_to("login", socket_pid, payload) do
    reg_pid = Registrar.UserAgent.add(%{socket_pid: socket_pid, payload: payload})
    Logger.info("Register pid created: #{inspect(reg_pid)}")

    {:ok, :login, %{my_user_id: payload.myUserId, extension: payload.extension}}
  end

  # Peer calls an extension or username. Dispatcher needs to do a lookup if
  # username or extension exists in the Registrar, otherwise it is a hearing
  # number to be forwarded to freeswitch for PSTN.

  defp route_to("call", socket_pid, payload) do
    Logger.info("route :call -- #{inspect(payload)} from #{inspect(socket_pid)}")

    # agents is the list of devices the callee is registered as
    # session_description includes sessionid, and peer info such as extension and peerid
    {:ok, callee_agents, session_description} = SessionController.handle_call({socket_pid, payload})

    destinations = Enum.map(callee_agents, fn {_pid, %{extension: extension, myUserId: peerid}} ->
      %{extension: extension, peerid: peerid}
    end)

    {
      :ok,
      :call,
      %{session: session_description, destinations: destinations}
    }
  end

  defp route_to("accept", pid, payload) do
    Logger.info("route :call -- #{inspect(payload)} from #{inspect(pid)}")

    # 4. User B responds with accept call invite, with action 'accept' and payload
    # of %{local_userid: String.t(), remote_users: [%{userid: String.t()}]}
    # 5. Phraze probes the payload from User B 'accept' and updates the Session of
    #   the User B
    SessionController.accept({pid, payload})

    {:ok, :accept, %{my_user_id: payload.myUserId, peers_id: []}}
  end

  # patron sends a message to start a vri call
  defp route_to("vri_call", pid, payload) do
    Logger.info("TODO: route :vri_call -- #{inspect(payload)} from #{inspect(pid)}")
    # Vri.Patron.add_to_waiting(pid, payload)
    # {:ok, agent_pid} = Vri.Agent.GetFirst()
  end

  # May want to test this using FunWithFlags when I am ready to add device
  # information to use for records
  defp route_to("vri_terp_join", pid, payload) do
    Logger.info("TODO: route :vri_terp_join -- #{inspect(payload)} from #{inspect(pid)}")

    {:ok}
  end

  defp route_to("ice_config", pid, payload) do
    Logger.info("TODO: route :ice_config -- #{inspect(payload)} from #{inspect(pid)}")
    # Session.Controller.ice_config(pid, channel, payload)
    {:ok}
  end

  # May want to test this using FunWithFlags when I am ready to add type
  # for routing
  defp route_to("sdp", pid, payload) do
    Logger.info("TODO: route :sdp -- #{inspect(payload)} from #{inspect(pid)}")
    # Session.Controller.sdp(ua_pid, channel, payload)
    {:ok}
  end

  defp route_to("ice_candidate", pid, payload) do
    Logger.info("TODO: route :ice_candidate -- #{inspect(payload)} from #{inspect(pid)}")
    # Session.Controller.ice_candidate(pid, channel, payload)
    {:ok}
  end

  # dont need to implement as part of first phase
  defp route_to("join_channel", _pid, payload) do
    Logger.info("TODO: implement join_channel")
    # peers_id could have a format such as [%{pid: t.number(), extension:
    # t.bitstring()}]
    {:ok, :login, %{my_user_id: payload.myUserId, peers_id: []}}
  end

  # TODO - describe what message role is. More of a UI thing, but is message
  # sent during a call and/or within channel?
  defp route_to("message", pid, payload) do
    Logger.info("TODO: route :message -- #{inspect(payload)} from #{inspect(pid)}")
    {:ok}
  end

  defp route_to(action, _pid, _payload) do
    Logger.warn("Unknown action: #{inspect(action)}")
    {:error, {:bad_action, action}}
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
  # defp register_ua(%{pid: _pid, uuid: _uuid, device: _device}) do
  #   IO.puts("ACD Dispatcher create new vri patron acd process from ACD module")
  #   {:ok}
  # end
end
