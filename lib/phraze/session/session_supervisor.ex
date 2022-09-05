defmodule Phraze.Session.SessionSupervisor do
  @moduledoc """
  Sessions are generated dynamically. A DynamicSupervisor is needed to regulate
  the states of each session. The controller will assign this supervisor to the
  Application plug.
  """

  use Supervisor, restart: :temporary

  alias Phraze.Session.{RtcChat, Vri, AiCall}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do

    {_pid, %{action: action}} = args

    options = [
      strategy: :one_for_one,
      max_seconds: 30
    ]

    children = case action do
      "call" -> [{RtcChat, args}]
      "vri_call" -> [{Vri, args}]
      "ai_call" -> [{AiChat, args}]
    end

    Supervisor.init(children, options)

  end
end
