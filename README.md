[![Phraze Github Actions Test](https://github.com/omnipotentuser/phraze/actions/workflows/github-action.yml/badge.svg)](https://github.com/omnipotentuser/phraze/actions/workflows/github-action.yml)

# Phraze

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
  * check lib/release_tasks.ex
  * MIX_ENV=prod mix assets.deploy
  * prune by running mix phx.digest.clean --all
  * mix distillery.init

## Run local environment

    # Running in production we set up local environment  
    `. .env`

## Running Distillery and creating releases

Release created at _build/dev/rel/phraze!

    # To start your system
    _build/dev/rel/phraze/bin/phraze start

Once the release is running:

    # To connect to it remotely
    _build/dev/rel/phraze/bin/phraze remote

    # To stop it gracefully (you may also send SIGINT/SIGTERM)
    _build/dev/rel/phraze/bin/phraze stop

To list all commands:

    _build/dev/rel/phraze/bin/phraze

## Running on Docker

  * docker image build -t phraze:latest .
  * docker run --network=host -e MIX_ENV=prod phraze:latest
  * docker run --network=host -e phraze:latest
  * to use docker-compose, run `source .env` before running `docker-compose up`. You may set port or other environmental variables such as MIX_ENV.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
