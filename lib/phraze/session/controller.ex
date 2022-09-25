defmodule Phraze.Session.Controller do
  @moduledoc """
  The Controller's primary responsibility is to administer the sessions. It
  controls as the interface to the type of sessions.
  """

  alias Phraze.SessionRunner
  alias Phraze.Acd.Registrar.UserAgent
  alias Phraze.Session.{Session, SessionSupervisor, RtcChat}
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

    payload
    |> find_session()
    |> build_callee_agents(Map.get(payload, :extension))
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

  # Look up SessionRegistry and see if Session exists based on tuple {extension, userid}. If not, then
  # create a new Session.
  defp find_session(payload) do
    session_id = Map.get(payload, :session_id)
    if session_id do
      case RtcChat.get_session(session_id) do
        {:ok, %Session{session_id: s_id, peers: peers}} ->
          {:ok, %Session{session_id: s_id, peers: peers}}
        {:error, reason} ->
          {:error, reason}
      end
    else

      # probably want to move this section to Session.new()
      session = Session.new(payload)

      # build_session_description()
      DynamicSupervisor.start_child(SessionRunner, {SessionSupervisor, {session}})
      # session =  %Session{session_id: s_id, peers: peers}
      case RtcChat.get_session(Map.get(session, :session_id)) do
        {:ok, %Session{session_id: s_id, peers: peers}} ->
          {:ok, %Session{session_id: s_id, peers: peers}}
        {:error, reason} ->
          {:error, reason}
      end
    end
  end # Map.get(:session_id) # returns nil if not found

  # TODO error check from session value
  defp build_callee_agents({:ok, session}, extension) do
    case UserAgent.get(%{extension: extension}) do
      [{_pid, callee_agents}] ->
        {:ok, session, callee_agents}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_callee_agents({:error, reason}, extension) do
    Logger.warn("find_session error #{reason} for extension #{extension}")
    {:error, reason}
  end
end
