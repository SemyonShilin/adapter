defmodule Adapter.InstanceGenServer do
  use Export.Ruby
  use GenServer

  def start_link(args) do
    name = String.to_atom("runy_#{hd(args)}")
    GenServer.start_link(__MODULE__, tl(args), [{:name, name}])
  end

  def init(args) do
    [instance_name, token] = args
    instance = Adapter.Instance.new(instance_name)
    instance_name |> run([instance, token])
    {:ok, instance}
  end

  def run(instance_name, args) do
    case instance_name do
      :adapter -> spawn_link Adapter.InstanceGenServer, :adapter, [args]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [args]
    end
  end

  def adapter([pid, token]) do
    child_pid = pid |> Ruby.call("bot.rb", "run_bot", [pid, token, name: "run_bot"])
    {:ok, child_pid}
  end

  def listening([pid, token]) do
    child_pid = pid |> Ruby.call("bot.rb", "register_handler", [token, name: "register_handler"])
    {:ok, child_pid}
  end
end
