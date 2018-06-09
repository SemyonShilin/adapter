defmodule Adapter.BotSupervisor do
  use Supervisor, restart: :temporary

  def start_link(:ok, token) do
    Supervisor.start_link(__MODULE__, token)
  end

  def init(token) do
    {adapter_id, listener_id} = id_generator()
    children = [
      Supervisor.child_spec({Adapter.InstanceGenServer, [adapter_id, :adapter, token]}, id: adapter_id),
      Supervisor.child_spec({Adapter.InstanceGenServer, [listener_id, :listening, token]}, id: listener_id)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp id_generator do
    {String.to_atom("adapter_#{SecureRandom.base64(8)}"), String.to_atom("listener_#{SecureRandom.base64(8)}")}
  end

  def stop(pid, name) do
    bot = Adapter.Bots.get_by_bot(uid: name)
    Supervisor.which_children(pid)
    |> Enum.each(fn(tuple) ->
      gen_server_pid = elem(tuple, 1)
      if Mix.env == :prod, do: Adapter.InstanceGenServer.stop(gen_server_pid, bot.token)
      gen_server_pid
      |> Process.info |> Keyword.get(:links)
      |>Enum.drop(-1) |> Enum.each(fn(e) ->
        :ruby.stop(e)
      end) # process with port
    end)
  end
end
