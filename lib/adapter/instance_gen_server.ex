defmodule Adapter.InstanceGenServer do
  use Export.Ruby
  use GenServer

  def start_link(args) do
    name = String.to_atom("runy_#{elem(args, 1)}")
    GenServer.start_link(__MODULE__, elem(args, 0), [{:name, name}])
  end

  def init(args) do
    instance = Adapter.Instance.new(args)
    run(args, instance)
    {:ok, instance}
  end

  def run(arg, instance) do
    case arg do
      :adapter -> spawn_link Adapter.InstanceGenServer, :adapter, [instance]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [instance]
    end
  end

  def adapter(pid) do
    pid = pid |> Ruby.call("test.rb", "run_bot", [pid , name: "run_bot"])
    {:ok, pid}
  end

  def listening(pid) do
    pid2 = pid |> Ruby.call("test.rb", "register_handler", [name: "register_handler"])
    {:ok, pid2}
  end
end
