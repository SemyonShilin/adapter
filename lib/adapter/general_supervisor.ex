defmodule Adapter.GeneralSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
#      {Adapter.Repo, []},
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      {Adapter.Registry, name: Adapter.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
