defmodule Adapter.BotPid do
  use DynamicSupervisor
  use Export.Ruby

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: arg)
#    Adapter.BotPid.start_child(arg)
  end

  def start_child(arg) do
    spec = { Adapter.InstanceGenServer, arg }
    DynamicSupervisor.start_child(arg, spec)
  end

  def init(arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [arg]
    )
  end
end
