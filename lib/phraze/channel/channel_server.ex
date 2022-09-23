defmodule ChannelServer do
  @moduledoc """
  Server that holds the list of channels and users belonging to each channel.
  Getter and Setter and carries the state of users.

  A Channel Registry is used to carry the name of the channels and carry a list
  of users and its pid. Each time a ChannelServer gets spawned from the ChannelSupervisor, its id gets
  assigned to the ChannelRegistry.

  Channel is a room of users visible to each other. Users in the channel may
  send a message to target peer or broadcast to all. A user may belong to
  multiple channels.

  Channels is a way for users to announce their presence. By showing the
  presence status, users can trigger a rtc call chat session with one or group
  of peers.

  Interpreters can also register and join channels they are authorized to
  connect to. This will allow patrons to see interpreters and their status
  activity so that this way they can create their own queues based on selected
  interpreters from the channel interpreter list. Either by clicking or toggling
  in order to begin the attempt for connecting to an interpreter.


  """

  use GenServer, restart: :transient
  require Logger

  defstruct [:uuid, gender: "none", max_duration: 120, status: "ready"]

  def start_link(args) do
    args =
      if Keyword.has_key?(args, :name) do
        args
      else
        Keyword.put(args, :name, "friends")
      end

    name = Keyword.get(args, :name)
    type = Keyword.get(args, :type)
    GenServer.start_link(__MODULE__, args, name: via(name, type))
  end

  def init(_) do
    {:ok, []}
  end

  def add(user) do
    Logger.info("add #{user} to the ChannelRegistry")
  end

  def update(user) do
    Logger.info("update #{user} in the ChannelRegistry")
  end

  defp via(key, value) do
    {:via, Registry, {Phraze.ChannelRegistry, key, value}}
  end
end
