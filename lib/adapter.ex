defmodule Adapter do
  use Application

  alias Plug.Adapters.Cowboy

  def start(_type, _args) do
    Envy.auto_load
    import Supervisor.Spec
    if System.get_env("MIX_ENV") == "dev", do: :observer.start

    options = [
      dispatch: [
        {:_, [
          {"/wobserver/ws", Wobserver.Web.Client, []},
          {:_, Cowboy.Handler, {Adapter.Router, []}}
        ]}
      ],
    ]

    children = [
      supervisor(Adapter.Repo, []),
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      {Adapter.Registry, name: Adapter.Registry},
      supervisor(Adapter.Endpoint, []),
#      Cowboy.child_spec(:http, Adapter.Router, [], options),
    ]

    opts = [strategy: :one_for_one, name: Adapter.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Adapter.Endpoint.config_change(changed, removed)
    :ok
  end
end
