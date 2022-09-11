defmodule Phraze.Session.RtcChat do
  @moduledoc """
  RtcChat holds session of individual connected peer information. This also
  means that each patron has its own extension number. session id and call in number will be
  provided.
  """

  use GenServer, restart: :transient
  require Logger

  # defstruct [:session_id, :updated_at, created_at: DateTime.utc_now, status: "active"]

  # create a new session that carries the state of the peers and information about the session
  # payload =
  # %{ pid, %{action: String.t(), peer: String.t(), myUserId: String.t(), sessionid: String.t() }}
  def start_link(session) do
    id = Map.get(session, :session_id)
    session = Map.merge(session, %{
      created_at: DateTime.utc_now,
      node: Node.self,
      status: :provisioning
    })
    GenServer.start_link(__MODULE__, payload, name: via(id, session))
  end

  def init(session) do
    Logger.info("#{payload} store payload stuff into state")

    {:ok, session, {:continue, :session_create}}
  end

  def handle_continue(:session_create, session) do
    Logger.info("handle_continue with CDR #{inspect session}")
    # can update state of session from CDR and send below
    {:stop, :normal, session}
  end

  def get_session(session_id) do
    Registry.lookup(Phraze.SessionRegistry, session_id)
  end

  def update_session() do

  end

  def add(user) do
    Logger.info("add #{user} to the SessionRegistry")
  end

  def update(user) do
    Logger.info("update #{user} in the SessionRegistry")
  end

  defp via(session_id, session) do
    {:via, Registry, {Phraze.SessionRegistry, session_id, session}}
  end
end