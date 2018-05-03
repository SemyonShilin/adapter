defmodule Adapter.GeneralSupervisor do
  use Supervisor
  #  Adapter.MessengersSupervisor.start_new_messenger(Adapter.MessengerSupervisor)
  #  Adapter.MessengerSupervisor.start_new_bot(:bot_1, "TOKEN1")
  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      {Adapter.Registry, name: Adapter.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
