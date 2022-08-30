defmodule Phraze.Session.ChannelSupervisor do
  @moduledoc """
  Channels are generated dynamically. A DynamicSupervisor is needed to regulate
  the states of each channel. The channel controller will coordinate with this
  supervisor the channel server.
  """

  use Supervisor, restart: :temporary

  alias Phraze.Channel.ChannelServer

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {ChannelServer, args}
    ]

    options = [
      strategy: :one_for_one,
      max_seconds: 30
    ]

    Supervisor.init(children, options)
  end
end
