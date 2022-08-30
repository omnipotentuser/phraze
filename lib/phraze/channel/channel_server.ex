defmodule ChannelServer do
  @moduledoc """
  Server that holds the list of channels and users belonging to each channel.
  Getter and Setter and carries the state of users.

  Relies on GenServer. Each channel Server represents a channel name which may
  be obtained from the Registry. A DynamicSupervisor is needed to supervise each
  Server and coordinate through the Registry.

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
end
