defmodule Phraze.Session.SessionSupervisor do
  @moduledoc """
  Sessions are generated dynamically. A DynamicSupervisor is needed to regulate
  the states of each session. The controller will assign this supervisor to the
  Application plug.
  """

  use Supervisor, restart: :temporary

  alias Phraze.Session.Channel

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {Channel, args}
    ]

    options = [
      strategy: :one_for_one,
      max_seconds: 30
    ]

    Supervisor.init(children, options)
  end
end
