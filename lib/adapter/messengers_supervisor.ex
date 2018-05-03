defmodule Adapter.MessengersSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_new_messanger(opts) do
    child = Supervisor.child_spec({Adapter.MessengerSupervisor, opts}, id: opts[:name])
    Supervisor.start_child(__MODULE__, child)
  end

  def init(:ok) do
    children = [
#      Supervisor.child_spec({Adapter.MessengerSupervisor, [name: Adapter.MessengerSupervisor]}, id: Adapter.MessengerSupervisor)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
