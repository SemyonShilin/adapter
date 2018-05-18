defmodule Adapter.MessengerSupervisor do
  @moduledoc false

  use DynamicSupervisor, restart: :temporary

  @name Adapter.MessengerSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(@name, :ok)
  end

  def start_new_bot(pid, token) do
    spec = {Adapter.BotSupervisor, token}
    DynamicSupervisor.start_child(pid, spec)
  end

  def init(initial_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [initial_arg]
    )
  end

  def stop(pid) do
    Supervisor.stop(pid, :normal)
  end
end
