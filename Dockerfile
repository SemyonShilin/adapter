FROM elixir:1.6.4

RUN apt-get update && apt-get install -y inotify-tools build-essential --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force
RUN mix archive.install --force  https://github.com/phoenixframework/archives/raw/master/phx_new-1.3.3.ez

RUN mkdir -p /usr/src/app
COPY . /usr/src/app
RUN mkdir -p /usr/src/app/priv/db/mnesia
RUN chmod 777 /usr/src/app/priv/db/mnesia

WORKDIR /usr/src/app

RUN mix deps.get && mix deps.compile
RUN mix ecto.create && mix ecto.migrate
RUN cd /usr/src/app
