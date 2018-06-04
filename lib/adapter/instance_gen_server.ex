#defmodule Adapter.InstanceGenServer do
#  @moduledoc false
#
#  use Export.Ruby
#  use GenServer
#
#  def start_link(token, _args) do
#    GenServer.start_link(__MODULE__, token, [])
#  end
#
#  def init(token) do
##    {instance_name, token} = args
#    state = start_libs |> IO.inspect
#    new_state = start_methods(token, state)  |> IO.inspect
#    {:ok, new_state}
#  end
#
#  def stop(pid, token) do
#    GenServer.call(pid, token)
#  end
#
#  def run(instance_name, args) do
#    pid = spawn_link Adapter.InstanceGenServer, instance_name, [args]
##    Process.flag pid, :trap_exit, true
##    refs = Process.monitor(pid)
##    case instance_name do
##      :adapter   -> Adapter.InstanceGenServer.adapter(args)
##      :listening -> Adapter.InstanceGenServer.listening(args)
##    end
##    {refs, pid}
#  end
#
#  def adapter([pid, token]) do
#    IO.inspect pid
#    #TODO: last pid to nearest_parent_for(pid)
#
#    pid |> Ruby.call("main.rb", "run_bot", [pid, token, pid])
##    :ruby.stop(pid)
##    {:ok, pid}
#  end
#
#  def listening([pid, token]) do
#    IO.inspect pid
#    #TODO: last pid to nearest_parent_for(pid)
#
#    pid |> Ruby.call("main.rb", "register_handler", [pid, token, pid])
##    :ruby.stop(pid)
##    {:ok, pid}
#  end
#
#  def handle_call(token, _from, state) do
#    IO.inspect state
#    Process.demonitor(state)
#    pid = Map.get(state, "lib")
#    pid |> Ruby.call("main.rb", "stop_bot", [pid, token, nearest_parent_for(pid)])
#    :ruby.stop(state)
#    {:reply, :ok, state}
#  end
#
#  def handle_cast({:post_message, message}, state) do
#    IO.inspect "++++++++++++++++++++++++++++++++++"
#    IO.inspect message
#    IO.inspect state
#
#    :ruby.cast(state, Poison.encode!(message)) |> IO.inspect
#    IO.inspect "++++++++++++++++++++++++++++++++++"
#    {:noreply, state}
#  end
#
#  def handle_cast({:message, message}, state) do
#    IO.inspect "++++++++++++++++++++++++++++++++++"
#    IO.inspect message
#    IO.inspect state
#    :ruby.cast(state, message) |> IO.inspect
#    IO.inspect "++++++++++++++++++++++++++++++++++"
#    {:noreply, state}
#  end
#
#  def handle_info({:receive_message, msg}, state) do
#    IO.inspect "=================================="
#    IO.inspect msg
#    IO.inspect state
#    body = call_hub(msg)
#    find_current_listener_pid(state) |> :ruby.cast(body)
#    IO.inspect "=================================="
#    {:noreply, state}
#  end
#
##  def handle_info({t, ref, :process, _pid, reason}, state) do
##    IO.inspect "FUCK ALL!!!"
##    IO.inspect ref
##    IO.inspect _pid
##    IO.inspect reason
##    IO.inspect state
##    IO.inspect Process.exit(_pid, :kill)
##    {:noreply, state}
##  end
#
#  def handle_info(all, state) do
#    IO.inspect "FUCK ALL!!!"
#    IO.inspect all
#    IO.inspect state
#    {:noreply, state}
#  end
#
#  def terminate(_msg, state) do
#    IO.inspect "FUCK!!!!!"
#    IO.inspect state
#    {:noreply, state}
#  end
#
#  defp nearest_parent_for(pid, index \\ 0) do
#    {:ok, dictionary} = Keyword.fetch(Process.info(pid), :dictionary)
#    {:ok, ancestors} = Keyword.fetch(dictionary, :"$ancestors")
#    case index do
#      0 -> List.first(ancestors) |> Process.whereis()
#      _ -> Enum.at(ancestors, index)
#    end
#  end
#
#  defp call_hub(message) do
#    HTTPoison.start
#    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post System.get_env("DCH_POST"), message, [{"Content-Type", "application/json"}] |> IO.inspect
#    body
#  end
#
#  defp find_current_listener_pid(state) do
#    find_pid = &(if String.starts_with?("#{elem(&1, 0)}", "listener"), do: elem(&1, 0))
#    nearest_parent_for(state, 1)
#    |> Supervisor.which_children()
#    |> Enum.find_value(find_pid)
#  end
#
#  defp start_libs do
##    %{}
##    |> Map.put("adapter_lib", Adapter.Instance.new(:adapter))
##    |> Map.put("listening_lib", Adapter.Instance.new(:listening))
#    state =
#      with pid <- Adapter.Instance.new(:adapter),
#           Process.link(pid)
#        do
#        %{} |> Map.put("adapter_lib", Adapter.Instance.new(:adapter))
#      end
#    with pid2 <- Adapter.Instance.new(:adapter),
#         Process.link(pid2)
#      do
#      state |> Map.put("listening_lib", Adapter.Instance.new(:listening))
#    end
#  end
#
#  defp start_methods(token, state) do
#    state
#    |> Map.put("adapter_method", run(:adapter, [Map.get(state, "adapter_lib"), token]))
#    |> Map.put("listening_method",  run(:listening, [Map.get(state, "listening_lib"), token]))
#  end
#end
#Process.info(pid) |> Keyword.get(:links) |> List.first |> Process.info |> Keyword.get(:links) |> List.first |> Port.close


defmodule Adapter.InstanceGenServer do
  @moduledoc false

  use Export.Ruby
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, tl(args), [{:name, hd(args)}])
  end

  def init(args) do
    [instance_name, token] = args
    instance = Adapter.Instance.new(instance_name)
    Process.link(instance)
    state = instance_name |> run([instance, token])
    {:ok, instance}
  end

  def run(instance_name, args) do
#    pid = spawn_link Adapter.InstanceGenServer, instance_name, [args]
#    refs = Process.monitor(pid)
    case instance_name do
      :adapter   -> spawn_link Adapter.InstanceGenServer, :adapter, [args]
      :listening -> Adapter.InstanceGenServer.listening(args)
    end
#    {refs, pid}
  end

  def adapter([pid, token]) do
    pid |> Ruby.call("main.rb", "run_bot", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  def listening([pid, token]) do
    pid |> Ruby.call("main.rb", "register_handler", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  #  def stop_bot([pid, token]) do
  #    pid |> Ruby.call("main.rb", "stop_bot", [pid, token, nearest_parent_for(pid)])
  #
  #    {:ok, pid}
  #  end
  def stop(pid, token) do
    GenServer.call(pid, token)
  end

  def handle_call(token, _from, state) do
    IO.inspect token
    IO.inspect "1111111111111"

    #    Process.demonitor(state)
#    pid = Map.get(state, "adapter_lib")
    state |> Ruby.call("main.rb", "stop_bot", [state, token, state])
#    :ruby.stop(state)
    {:reply, :ok, state}
  end
#  Adapter.Registry.down {:bot, "bot_2"}

  def handle_cast({:post_message, message}, state) do
    IO.inspect "++++++++++++++++++++++++++++++++++"
    IO.inspect message
    IO.inspect state

    :ruby.cast(state, Poison.encode!(message)) |> IO.inspect
    IO.inspect "++++++++++++++++++++++++++++++++++"
    {:noreply, state}
  end

  def handle_cast({:message, message}, state) do
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
    body = call_hub(msg)
    find_current_listener_pid(state) |> :ruby.cast(body)
    IO.inspect "=================================="
    {:noreply, state}
  end

  def handle_info({t, ref, :process, _pid, reason}, state) do
    IO.inspect "FUCK ALL!!!"
    IO.inspect ref
    IO.inspect _pid
    IO.inspect reason
    IO.inspect state
    IO.inspect Process.exit(_pid, :kill)
    {:noreply, state}
  end

  def terminate(_msg, state) do
    IO.inspect "FUCK!!!!!"
    IO.inspect state
    {:noreply, state}
  end

  defp nearest_parent_for(pid, index \\ 0) do
    {:ok, dictionary} = Keyword.fetch(Process.info(pid), :dictionary)
    {:ok, ancestors} = Keyword.fetch(dictionary, :"$ancestors")
    case index do
      0 -> List.first(ancestors) |> Process.whereis()
      _ -> Enum.at(ancestors, index)
    end
  end

  defp call_hub(message) do
    HTTPoison.start
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post System.get_env("DCH_POST"), message, [{"Content-Type", "application/json"}] |> IO.inspect
    body
  end

  defp find_current_listener_pid(state) do
    find_pid = &(if String.starts_with?("#{elem(&1, 0)}", "listener"), do: elem(&1, 0))
    nearest_parent_for(state, 1)
    |> Supervisor.which_children()
    |> Enum.find_value(find_pid)
  end
end
