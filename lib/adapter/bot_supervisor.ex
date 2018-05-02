defmodule Adapter.BotSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, _opts)
  end

  def init(:ok) do
    {adapter_id, listener_id} = id_generator()
    children = [
      Supervisor.child_spec({Adapter.InstanceGenServer, {:adapter, adapter_id}}, id: adapter_id),
      Supervisor.child_spec({Adapter.InstanceGenServer, {:listening, listener_id}}, id: listener_id)
    ]

    Supervisor.init(children, strategy: :one_for_all) #|> IO.inspect
  end

  defp id_generator do
    {String.to_atom(SecureRandom.base64(8)), String.to_atom(SecureRandom.base64(8))}
  end
end
