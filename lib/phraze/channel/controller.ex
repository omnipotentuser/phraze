defmodule Phraze.Channel.Controller do
  @moduledoc """
  Channel.Controller's task is to act as an initiator for the DynamicSupervisor
  to create new Channels, and to do checks, regulate the channels and send data
  to be serialized
  """
  require Logger
  alias Phraze.ChannelRunner
  alias Phraze.Channel.ChannelSupervisor

  # PURPOSE: Channel acts as a connection between one or more users.

  # The users may be able to send instant messages, files, and connect through
  # webrtc to others. As of now, there is no concept of namespaces, but rather,
  # the idea is to treat this as a contact list, similar to SMS test and phone
  # contact list. Groups may be created to send and connect as a group. The
  # database will need to be envisioned for each user to preserve a list of
  # groups of users.

  # Two defined groups that are immutable are 'peers' and 'interpreters'

  @spec create_channel(String.t()) :: {Atom.t()}
  def create_channel(channel_name) do
    Logger.info("create_channel #{channel_name}")

    # does channel exist? If not, start child
    DynamicSupervisor.start_child(ChannelRunner, {ChannelSupervisor, channel_name})
    {:ok}
  end
end
