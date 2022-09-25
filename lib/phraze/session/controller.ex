defmodule Phraze.Session.Controller do
  @moduledoc """
  The Controller's primary responsibility is to administer the sessions. It
  controls as the interface to the type of sessions.
  """

  alias Phraze.SessionRunner
  alias Phraze.Acd.Registrar.UserAgent
  alias Phraze.Session.{Session, Peer, SessionSupervisor, RtcChat}
  require Logger

  # Need to add functions to get, create, insert, lookups sessions
  # i.e. SessionRegistry.select(Phraze.SessionRegistry, [{match_all, guards, map_result}])

  # 2. Phraze looks up A in Session, if no Session, a new Session is created
  # that stores the user A pid, uuid, and username
  # 3. Phraze sends action 'call' to user B with payload of %{ action: 'call',
  # remote_peer: [%{username: String.t(), userid: String.t()}]}
  #
  # creates a SessionSupervisor Supervisor
  @spec handle_call({pid(), map()}) :: {atom(), map, map}
  def handle_call({socket_pid, payload}) do
    Logger.info("create_session #{socket_pid}")

    # DynamicSupervisor creates new child through its Supervisor of RtcChat which uses :via

    # Look up SessionRegistry and see if Session exists based on tuple {extension, userid}. If not, then
    # create a new Session.

    # May be better to pipe though functions to build session and pass to destination
    with session_id when session_id != nil <- Map.get(payload, :session_id),
         [{_pid, %Session{} = session}] <- RtcChat.get_session(session_id),
         session_description <- Map.take(session, [:peers, :session_id]),
         callee_agents <- UserAgent.get(Map.get(payload, :extension)) do
      {:ok, callee_agents, session_description}
    else
      _ ->
        # create a new session then do a lookup in the registry to get the session
        session = %Session{
          session_id: UUID.uuid4(),
          action: payload.action,
          peers: [
            %Peer{
              extension: payload.from_extension,
              user_id: payload.from_user_id
            }
          ]
        }

        DynamicSupervisor.start_child(SessionRunner, {SessionSupervisor, {session}})
        [{_pid, callee_agents}] = UserAgent.get(%{extension: Map.get(payload, :extension)})

        [{_pid, %Session{session_id: s_id, peers: peers}}] =
          RtcChat.get_session(Map.get(session, :session_id))

        session_description = %{session_id: s_id, peers: peers}

        {:ok, callee_agents, session_description}
    end
  end

  def accept({pid, payload}) do
    Logger.info("accept #{pid}, #{payload}")

    # search RtcChat Session registry based on:
    # guards = [:==, :"$3", ...?]
    {:ok}
  end

  def reject({pid, payload}) do
    Logger.info("reject #{pid}, #{payload}")
    {:ok}
  end

  def miss({pid, payload}) do
    Logger.info("miss #{pid}, #{payload}")
    {:ok}
  end

  # TODO - figure out what parameters should be used
  defp search_registry() do
    Logger.info("search_registry")
  end
end
