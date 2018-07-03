# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config


# General application configuration
# Configures the endpoint
config :adapter, AdapterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "K/vNxoiNreQwwGeV5mgHmr3JQtWlkuYkWG8+S7Osgv2kBQPbdk8x8kFQY9mPvpyT",
  render_errors: [view: AdapterWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Adapter.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :wobserver,
       mode: :plug,
       remote_url_prefix: "/wobserver"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :adapter,
       ecto_repos: [Adapter.Repo]

config :adapter, Adapter.Repo,
       adapter: EctoMnesia.Adapter,
       prov: 'priv/db/mnesia',
       host: :"adapter@127.0.0.1",
       storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

config :ecto_mnesia,
       host: :"adapter@127.0.0.1",
       storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

config :mnesia,
       host: :"adapter@127.0.0.1",
       storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
