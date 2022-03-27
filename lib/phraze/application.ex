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
      FunWithFlags.Supervisor,
      # Start a worker by calling: Phraze.Worker.start_link(arg)
      # {Phraze.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Phraze.Router,
        options: [
          dispatch: dispatch(),
          port: 1337,
          certfile: "/etc/letsencrypt/live/bovav.com/fullchain.pem",
          keyfile: "/etc/letsencrypt/live/bovav.com/fullchain.pem",
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Phraze
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phraze.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/ws/signaler", Phraze.SocketHandler, []},
          {:_, Plug.Cowboy.Handler, {Phraze.Router, []}}
        ]
      }
    ]
  end
end
