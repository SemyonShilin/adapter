defmodule Adapter.MessengerSupervisor do
  use Supervisor

  @name Adapter.MessengerSupervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, _opts)
  end

  def start_bot do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      Supervisor.child_spec({Adapter.BotSupervisor, [name: :bot_1]}, id: :bot_1),
      Supervisor.child_spec({Adapter.BotSupervisor, [name: :bot_2]}, id: :bot_2)
    ]

    Supervisor.init(children, strategy: :one_for_all)# |> IO.inspect
  end
end
