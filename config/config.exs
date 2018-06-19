# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config


# General application configuration
config :adapter,
  ecto_repos: [Adapter.Repo]

config :adapter, Adapter.Repo,
       adapter: EctoMnesia.Adapter,
       host: {:system, :atom, "localhost", Kernel.node()},
       storage_type: {:system, :atom, "ordered_set", :disc_copies}
config :mnesia,
       dir: 'priv/db/mnesia'

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


config :adapter, :agala_telegram,
      name: "fisrt",
      token: "390126265:AAGokHwWau7N7sd9Vga0g_qE3-Th9gNcXME"
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
