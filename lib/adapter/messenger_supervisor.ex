defmodule Adapter.MessengerSupervisor do
  use DynamicSupervisor

  @name Adapter.MessengerSupervisor

  def start_link(name) do
    DynamicSupervisor.start_link(@name, :ok, name: name)
  end

  def start_new_bot(messenger, token) do
    spec = { Adapter.BotSupervisor, System.get_env(token) }
    DynamicSupervisor.start_child(messenger, spec)
  end

  def init(initial_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [initial_arg]
    )
  end
end
