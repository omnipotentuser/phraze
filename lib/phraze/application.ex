defmodule Phraze.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    session_child_config = [
      strategy: :one_for_one,
      name: Phraze.SessionDispatcher,
      max_seconds: 30
    ]
    scheme = Application.get_env(:phraze, :scheme)
    options = Application.get_env(:phraze, :cowboy)
    children = [
      Phraze.Repo,
      FunWithFlags.Supervisor,
      Plug.Cowboy.child_spec(
        scheme: scheme,
        plug: Phraze.Router,
        options: options[:network_info]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Phraze
      ),
      Phraze.Acd.Vri.Agent,
      Phraze.Acd.Vri.Patron,
      Phraze.Acd.Vrs.Agent,
      Phraze.Acd.Vrs.Patron,
      Phraze.Acd.Registrar.UserAgent,
      {Registry, keys: :unique, name: Phraze.SessionRegistry},
      {DynamicSupervisor, session_child_config}
    ]

    Logger.info("Application started, using #{scheme}.")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phraze.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
