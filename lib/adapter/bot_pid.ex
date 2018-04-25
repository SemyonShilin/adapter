defmodule Adapter.BotPid do
  use DynamicSupervisor
  use Export.Ruby
#  Adapter.BotPid.start_child :listening
#  children = [{DynamicSupervisor, strategy: :one_for_one, name: Adapter.BotPid }]
#  Supervisor.start_link(children, strategy: :one_for_one)
#  DynamicSupervisor.start_child Adapter.BotPid, { Adapter.InstanceGenServer,  :adapter }
  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
    Adapter.BotPid.start_child(arg)
  end

  def start_child(arg) do
    spec = { Adapter.InstanceGenServer, arg }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(arg) do
    IO.inspect arg
    IO.inspect "DynamicSupervisor"

    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [arg]
    )
  end
end
