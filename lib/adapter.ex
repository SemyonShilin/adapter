defmodule Adapter do
  @moduledoc """
    App module
  """

  use Application

  def start(_type, _args) do
    if System.get_env("MIX_ENV") == "dev"  do
      Envy.auto_load
      :observer.start
    end

    :mnesia.info |> IO.inspect
    import Supervisor.Spec

    children = [
      Adapter.Repo,
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      {Adapter.Registry, name: Adapter.Registry},
      supervisor(Adapter.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Adapter.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Adapter.Endpoint.config_change(changed, removed)
    :ok
  end
end
