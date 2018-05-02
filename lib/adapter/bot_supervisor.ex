defmodule Adapter.BotSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, hd(args), tl(args))
  end

  def init(token) do
    {adapter_id, listener_id} = id_generator()
    children = [
      Supervisor.child_spec({Adapter.InstanceGenServer, [adapter_id, :adapter, token]}, id: adapter_id),
      Supervisor.child_spec({Adapter.InstanceGenServer, [listener_id, :listening, token]}, id: listener_id)
    ]

    Supervisor.init(children, strategy: :one_for_all) #|> IO.inspect
  end

  defp id_generator do
    {String.to_atom(SecureRandom.base64(8)), String.to_atom(SecureRandom.base64(8))}
  end
end
