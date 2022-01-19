defmodule Phraze.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Phraze.Repo,
      # Start the Telemetry supervisor
      PhrazeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Phraze.PubSub},
      # Start the Endpoint (http/https)
      PhrazeWeb.Presence,
      PhrazeWeb.Endpoint,
      PhrazeWeb.Stun,
      FunWithFlags.Supervisor,
      # Start a worker by calling: Phraze.Worker.start_link(arg)
      # {Phraze.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phraze.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhrazeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
