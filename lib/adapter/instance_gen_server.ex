defmodule Adapter.InstanceGenServer do
  use Export.Ruby
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, tl(args), [{:name, hd(args)}])
  end

  def init(args) do
    [instance_name, token] = args
    instance = Adapter.Instance.new(instance_name)
    instance_name |> run([instance, token])
    {:ok, instance}
  end

  def run(instance_name, args) do
    case instance_name do
      :adapter   -> spawn_link Adapter.InstanceGenServer, :adapter, [args]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [args]
    end
  end

  def adapter([pid, token]) do
    pid |> Ruby.call("main.rb", "run_bot", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  def listening([pid, token]) do
    pid |> Ruby.call("main.rb", "register_handler", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  def handle_cast({:post_message, message}, state) do
    IO.inspect "++++++++++++++++++++++++++++++++++"
    IO.inspect message
    IO.inspect state
    :ruby.cast(state, message) |> IO.inspect
    IO.inspect "++++++++++++++++++++++++++++++++++"
    {:noreply, state}
  end

  def handle_info({:receive_message, msg}, state) do
    IO.inspect "=================================="
    IO.inspect msg
    IO.inspect state
    call_dch(msg) |> IO.inspect
    IO.inspect "=================================="
    {:noreply, state}
  end

  def terminate(_msg, state) do
    IO.inspect "terminate11111111"
    IO.inspect state
    IO.inspect  _msg
    {:noreply, state}
  end

  def nearest_parent_for(pid) do
    {:ok, dictionary} = Keyword.fetch(Process.info(pid), :dictionary)
    {:ok, ancestors} = Keyword.fetch(dictionary, :"$ancestors")
    List.first(ancestors) |> Process.whereis()
  end

  def call_dch(message) do
    HTTPoison.start
    HTTPoison.post System.get_env("DCH_POST"), message, [{"Content-Type", "application/json"}]
  end
end
