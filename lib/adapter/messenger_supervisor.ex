defmodule Adapter.MessengerSupervisor do
  use Supervisor

  @name Adapter.MessengerSupervisor

  def start_link(_opts) do
    Supervisor.start_link(@name, :ok, _opts)
  end

  def start_new_bot(opts, token) do
    Supervisor.start_child(@name, Supervisor.child_spec({Adapter.BotSupervisor, [System.get_env(token), opts]}, id: opts[:name]))
  end

  def init(:ok) do
#    children = [
#      Supervisor.child_spec({Adapter.BotSupervisor, [System.get_env("TOKEN1"), name: :bot_1]}, id: :bot_1),
#      Supervisor.child_spec({Adapter.BotSupervisor, [System.get_env("TOKEN2"), name: :bot_2]}, id: :bot_2)
#    ]

    Supervisor.init([], strategy: :one_for_all)# |> IO.inspect
  end
end
