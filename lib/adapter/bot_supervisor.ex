#defmodule Adapter.BotSupervisor do
##  use Supervisor, restart: :temporary
##
##  def start_link(:ok, token) do
##    Supervisor.start_link(__MODULE__, token)
##  end
##
##  def init(token) do
##    {adapter_id, listener_id} = id_generator()
##    children = [
##      Supervisor.child_spec({Adapter.InstanceGenServer, [adapter_id, :adapter, token]}, id: adapter_id),
##      Supervisor.child_spec({Adapter.InstanceGenServer, [listener_id, :listening, token]}, id: listener_id)
##    ]
##
##    Supervisor.init(children, strategy: :one_for_one)
##  end
##
##  defp id_generator do
##    {String.to_atom("adapter_#{SecureRandom.base64(8)}"), String.to_atom("listener_#{SecureRandom.base64(8)}")}
##  end
#
#  def stop(pid, name) do
#    bot = Adapter.Bots.get_by_bot(name: name)
##    Supervisor.which_children(pid) |> IO.inspect
#    Supervisor.which_children(pid)
#    |> Enum.each(fn(tuple) ->
#      Process.info(elem(tuple, 1)) |> IO.inspect
##      with {:ok, links} <- Process.info(elem(tuple, 1))
##                           |> Keyword.fetch(:links)
##        do
##          IO.inspect links
##          IO.inspect "11111111"
###          Enum.each(links, fn(link) ->
###            IO.inspect link
###            Process.whereis(link) |> IO.inspect
###            Process.unlink(link) |> IO.inspect
####            Process.exit(link, :kill) |> IO.inspect
###            Adapter.InstanceGenServer.stop(elem(tuple, 1), bot.token)
###          end)
##      end
##      {:ok, links} =
##        Process.info(elem(tuple, 1))
##      |> Keyword.fetch(:links)
##      |> IO.inspect
##      |> Enum.each(fn(link) ->
##        Process.unlink(link) |> IO.inspect
##        Process.exit(link, :kill) |> IO.inspect
##      end)
#
##      Adapter.InstanceGenServer.stop(elem(tuple, 1))
#    end)
##    Supervisor.stop(pid)
##    Adapter.Registry.down {:bot, "bot_2"}
#  end
#
#  use DynamicSupervisor, restart: :temporary
#
#  @name Adapter.BotSupervisor
#
#  def start_link(:ok, token) do
#    {:ok, pid} = DynamicSupervisor.start_link(@name, token)
#    start_instance(pid, token)
##    start_instance(pid, {:listening, token})
#    {:ok, pid}
#  end
#
#  def start_instance(pid, token) do
#    spec = {Adapter.InstanceGenServer, token: token}
#    IO.inspect DynamicSupervisor.start_child(pid, spec)
#  end
#
#  def init(initial_arg) do
#    DynamicSupervisor.init(
#      strategy: :one_for_one,
#      extra_arguments: [initial_arg]
#    )
#  end
#end


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
#      IO.inspect tuple
      gen_server_pid = elem(tuple, 1)
      Adapter.InstanceGenServer.stop(gen_server_pid, bot.token)
      gen_server_pid
      |> Process.info |> Keyword.get(:links)
      |>Enum.drop(-1) |> Enum.each(fn(e) ->
        :ruby.stop(e)
      end) # process with port
    end)
  end
end
