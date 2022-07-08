defmodule Phraze.Session.Controller do
  @moduledoc """
  Sessions are generated dynamically. A DynamicSupervisor is needed to regulate
  the states of each session. This is where the Controller comes in.
  """


  alias Phraze.{SessionDispatcher, Session.SessionSupervisor}

  def start_job(args) do

    DynamicSupervisor.start_child(SessionDispatcher, {SessionSupervisor, args})

  end

  # Need to add functions to get, create, insert, lookups sessions
  # i.e. Registry.select(Phraze.SessionRegistry, [{match_all, guards, map_result}])

end
