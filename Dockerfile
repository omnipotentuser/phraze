FROM elixir:1.13.1

# Setup software package dependencies for Phoenix build
RUN mix local.hex --force \
  && apt-get update \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash \
  && apt-get install -y apt-utils \
  && apt-get install -y nodejs \
  && apt-get install -y build-essential \
  && apt-get install -y inotify-tools \
  && mix archive.install --force hex phx_new 1.6.5 \
  && mix local.rebar --force

# Copy over all the necessary application files and directories
WORKDIR /phraze

COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies
RUN mix deps.get
RUN mix deps.compile

EXPOSE 4040

CMD ["mix", "phx.server"]
