defmodule Phraze.Session.RtcChat do
  @moduledoc """
  RtcChat holds session of individual connected peer information. This also
  means that each patron has its own extension number. session id and call in number will be
  provided.
  """

  use GenServer, restart: :transient
  require Logger

  defstruct [:sessionid, :updated_at, created_at: DateTime.utc_now(), status: "active"]

  # create a new session that carries the state of the peers and information about the session
  # payload =
  # %{ pid, %{action: String.t(), peer: String.t(), myUserId: String.t(), sessionid: String.t() }}
  def start_link(payload) do

    # TODO break down payload and sort into structured state
    sessionid = 'foo'
    peers = 'boo'
    GenServer.start_link(__MODULE__, payload, name: via(sessionid, peers))
  end

  def init(payload) do
    Logger.info("#{payload} store payload stuff into state")
    {:ok, []}
  end

  def add(user) do
    Logger.info("add #{user} to the SessionRegistry")
  end

  def update(user) do
    Logger.info("update #{user} in the SessionRegistry")
  end

  defp via(key, value) do
    {:via, Registry, {Phraze.SessionRegistry, key, value}}
  end
end
