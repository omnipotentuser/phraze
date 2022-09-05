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
   @spec call_peer({pid(), map()}) :: {atom(), [{pid(), any}]}
  def call_peer({pid, payload}) do
    Logger.info("create_session #{pid}")

    # DynamicSupervisor creates new child through its Supervisor of RtcChat which uses :via

    # Look up SessionRegistry and see if Session exists based on tuple {extension, userid}. If not, then
    # create a new Session.

    sessionid = UUID.uuid4()
    payload = Map.merge(payload, %{sessionid: sessionid})

    DynamicSupervisor.start_child(SessionRunner, {SessionSupervisor, {pid, payload}})

    # get remote userid from PeerRegistrar
    # [{pid, %{extension: extension, myUserId: uid, status: available, action: action}} | _] =
    agents = Registry.lookup(Phraze.PeerRegistrar, payload.extension)
    {:ok, agents}
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
