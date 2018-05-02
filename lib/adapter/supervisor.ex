defmodule Adapter.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_bot do
    children = [
      Supervisor.child_spec({Adapter.BotPid, :adapter}, id: :adapter),
      Supervisor.child_spec({Adapter.BotPid, :listening}, id: :listening)
    ]
    Supervisor.start_child(Adapter.Supervisor, children)
  end

  def init(:ok) do
    children = [
      Supervisor.child_spec({Adapter.BotPid, :adapter}, id: :adapter),
      Supervisor.child_spec({Adapter.BotPid, :listening}, id: :listening),
      {Adapter.Registry, name: Adapter.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
