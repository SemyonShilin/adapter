defmodule Adapter.InstanceGenServer do
  use Export.Ruby
  use GenServer

  def start_link(arg, _fuck) do
    name = String.to_atom("runy_#{arg}")
    GenServer.start_link(__MODULE__, arg, [{:name, name}])
  end

  def init(arg) do
    instance = Adapter.Instance.new(arg) |> IO.inspect
    run(arg, instance)
#    GenServer.call(__MODULE__, {arg, instance})
    {:ok, instance}
  end

  def run(arg, instance) do
    pid = case arg do
      :adapter -> spawn_link Adapter.InstanceGenServer, :adapter, [instance]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [instance]
    end
    IO.inspect "run #{arg}"
    IO.inspect pid
    IO.inspect '==========='
  end

  def handle_cast(:adapter, state) do
    IO.inspect 11111
    pid = spawn_link Adapter.InstanceGenServer, :adapter, [state.adapter]
    {:noreply, pid}
  end

  def handle_cast(:listening, state) do
    IO.inspect 2222
    pid = spawn_link Adapter.InstanceGenServer, :adapter, [state.listening]
    {:noreply, pid}
  end

#  def handle_call({arg, instance}, from, _state) do
#    pid = case arg do
#      :adapter -> spawn_link Adapter.InstanceGenServer, :adapter, [instance]
#      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [instance]
#    end
#    {:ok, from, pid }
#  end

  def adapter(pid) do
    pid = pid |> Ruby.call("test.rb", "run_bot", [pid , name: "run_bot"])
    {:ok, pid}
  end

  def listening(pid) do
    pid2 = pid |> Ruby.call("test.rb", "register_handler", [name: "register_handler"])
    {:ok, pid2}
  end
end
