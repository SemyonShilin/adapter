defmodule Adapter.InstanceGenServer do
  use Export.Ruby
  use GenServer

  def start_link(arg, fuk) do
    IO.inspect "start_link Instance"
    IO.inspect arg
    IO.inspect fuk
    IO.inspect "start_link Instance"
    name = String.to_atom("runy_#{arg}")
    GenServer.start_link(__MODULE__, arg, [{:name, name}])
  end

  def init(arg) do
    IO.inspect "init Instance"

    IO.inspect arg

    instances = Adapter.Instance.new() |> IO.inspect
#    run(arg, instances)
    GenServer.cast(__MODULE__, arg)
    {:ok, instances}
  end

  def run(arg, instances) do
    pid = case arg do
      :adapter -> spawn_link Adapter.InstanceGenServer, :adapter, [instances.adapter]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [instances.listening]
    end
    IO.inspect pid
  end

  def handle_cast(:adapter, state) do
    IO.inspect 11111
    pid = spawn_link Adapter.InstanceGenServer, :adapter, [state.adapter] |> IO.inspect
    {:noreply, pid}
  end

  def handle_cast(:listening, state) do
    IO.inspect 2222
    pid = spawn_link Adapter.InstanceGenServer, :adapter, [state.listening] |> IO.inspect
    {:noreply, pid}
  end

  def handle_call(:listening, from, state) do
    {:ok, from, listening(state.listening) }
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
