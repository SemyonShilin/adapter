defmodule Adapter.MessengersSupervisor do
  use DynamicSupervisor, restart: :temporary

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_new_messenger() do
    spec = { Adapter.MessengerSupervisor, [] }
    DynamicSupervisor.start_child(__MODULE__, spec)
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
