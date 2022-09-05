defmodule Phraze.Session.Controller do
  @moduledoc """
  The Controller's primary responsibility is to administer the sessions. It
  controls as the interface to the type of sessions.
  """

  # alias Phraze.{SessionRegistry}
  require Logger

  # Need to add functions to get, create, insert, lookups sessions
  # i.e. SessionRegistry.select(Phraze.SessionRegistry, [{match_all, guards, map_result}])

  # 2. Phraze looks up A in Session, if no Session, a new Session is created
  # that stores the user A pid, uuid, and username
  # 3. Phraze sends action 'call' to user B with payload of %{ action: 'call',
  # remote_peer: [%{username: String.t(), userid: String.t()}]}
  # creates a SessionSupervisor Supervisor
   @spec handle_call({pid(), map()}) :: {atom(), [{pid(), any}]}
  def handle_call({socket_pid, payload}) do
    Logger.info("create_session #{socket_pid}")

    # DynamicSupervisor creates new child through its Supervisor of RtcChat which uses :via

    # Look up SessionRegistry and see if Session exists based on tuple {extension, userid}. If not, then
    # create a new Session.

    session = if payload.sessionid do
      SessionRegistry.lookup(payload.sessionid)
    end

    session_description = case length(session) do
      s when s > 0 ->
        # TODO - fix the parameters to show more than just session arg
        # such as [{extension, peerid}]
        Map.merge(payload, %{session: session})
      _ ->
        sessionid = UUID.uuid4()
        Map.merge(payload, %{sessionid: sessionid})
        DynamicSupervisor.start_child(SessionRunner, {SessionSupervisor, {socket_pid, payload}})
        payload
    end


    # get remote userid from PeerRegistrar
    # [{pid, %{extension: extension, myUserId: uid, status: available, action: action}} | _] =

    callee_agents = Registry.lookup(Phraze.PeerRegistrar, payload.extension)
    {:ok, callee_agents, session_description}
  end

  def accept({pid, payload}) do
    Logger.info("create_session #{pid}")

    # search RtcChat Session registry based on:
    # guards = [:==, :"$3", ...?]
    {:ok}
  end

  def reject({pid, payload}) do
    Logger.info("create_session #{pid}")
    {:ok}
  end

  def miss({pid, payload}) do
    Logger.info("create_session #{pid}")
    {:ok}
  end

  # TODO - figure out what parameters should be used
  defp search_registry() do
    Logger.info("search_registry")
  end
end
