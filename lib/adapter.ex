defmodule Adapter do
  @moduledoc """
    App module
  """

  use Application
  import Supervisor.Spec

  @sup_name Adapter.Supervisor

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: @sup_name]

    res = Supervisor.start_link(children(:init), opts)
    run_tools()
    Supervisor.start_child(@sup_name, children(:general))
    res
  end

  def config_change(changed, _new, removed) do
    Adapter.Endpoint.config_change(changed, removed)
    :ok
  end

  defp run_tools do
    :adapter
    |> Application.get_env(:env)
    |> run_tools()
  end

  defp run_tools(:dev) do
    Envy.auto_load
    :observer.start
  end

  defp run_tools(:prod) do
    Adapter.Tasks.ReleaseTasks.run
  end

  defp children(:init) do
    [
      Adapter.Repo,
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      supervisor(Adapter.Endpoint, [])
    ]
  end

  defp children(:general) do
    {Adapter.Registry, name: Adapter.Registry}
  end
end
