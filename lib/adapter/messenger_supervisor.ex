defmodule Adapter.MessengerSupervisor do
  use DynamicSupervisor, restart: :temporary

  @name Adapter.MessengerSupervisor

  def start_link(name) do
    DynamicSupervisor.start_link(@name, :ok, name: name)
  end

  def start_new_bot(messenger, token, pid \\ nil) do
    spec = { Adapter.BotSupervisor, System.get_env(token) }
    DynamicSupervisor.start_child(pid || messenger, spec)
  end

  def init(initial_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [initial_arg]
    )
  end
end
