defmodule Adapter.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(arg \\ []) do
    children = [
      Supervisor.child_spec({Adapter.BotPid, :adapter}, id: :adapter),
      Supervisor.child_spec({Adapter.BotPid, :listening}, id: :listening)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
