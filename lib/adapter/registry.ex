defmodule Adapter.Registry do
  @moduledoc "Модуль для реестра процессов"

  #  Adapter.Registry.create(Adapter.Registry, :telegram, {:bot_2, "TOKEN2"})
  #  Adapter.Registry.lookup(Adapter.Registry, {:telegram, :bot_2})
  #  GenServer.call(Adapter.Registry, {:create, :telegram})
  #  Adapter.Registry.create(Adapter.Registry, {:telegram, :bot_2})

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, {messenger, name}) do
    GenServer.call(server, {:lookup, {messenger, name}})
  end

  def lookup(server, messenger) do
    GenServer.call(server, {:lookup, messenger})
  end

  def create(server, messenger, {name, token}) do
    GenServer.cast(server, {:create, messenger, {name, token}})
  end

  def create(server, messenger) do
    GenServer.call(server, {:create, messenger})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def init(:ok) do
    messengers = %{}
    messengers_refs = %{}
    {:ok, {messengers, messengers_refs}}
  end

  def handle_call({:lookup, {messenger, name}}, _from, {messengers, _} = state) do
    if Map.has_key?(messengers, messenger) do
      {:reply, get_in(messengers, [messenger, :names, name]), state}
    else
      {:reply, "#{messenger} isn't up" |> String.capitalize, state}
    end
  end

  def handle_call({:lookup, messenger}, _from, {messengers, _} = state) do
    if Map.has_key?(messengers, messenger) do
      {:reply, Map.fetch(messengers, messenger), state}
    else
      {:reply, "#{messenger} isn't up" |> String.capitalize, state}
    end
  end

  def handle_call({:create, messenger}, _from, {messengers, _} = state) do
    if Map.has_key?(messengers, messenger) do
      {:reply, Map.fetch(messengers, messenger), state}
    else
      new_state = create_messenger(messenger, state)
      {:reply, new_state, new_state}
    end
  end

  def handle_cast({:create, messenger, {name, token}}, {messengers, messengers_refs} = state) do
    if Map.has_key?(messengers, messenger) do
      if Map.has_key?(get_names(messengers, messenger), name) do
        {:noreply, Map.fetch(get_names(messengers, messenger), name)}
      else
        messengers = create_bot({messengers, messenger}, {name, token})
        {:noreply, {messengers, messengers_refs}}
      end
    else
      {messengers, messengers_refs} = create_messenger(messenger, state)
      messengers = create_bot({messengers, messenger}, {name, token})
      {:noreply, {messengers, messengers_refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, :shutdown}, {messengers, messengers_refs} = state) do
    IO.puts '================'
    IO.inspect state
    IO.inspect _pid
    IO.inspect ref
    IO.puts '================'
    {name, refs} = Map.pop(messengers_refs, ref)
    names = Map.delete(messengers, name)

    {:noreply, {names, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {messengers, messengers_refs} = state) do
    IO.puts '!!!!!!!!!!!!!!!!!'
    IO.inspect state
    IO.inspect _pid
    IO.inspect _reason
    IO.puts '!!!!!!!!!!!!!!!!!'
    {name, refs} = Map.pop(messengers_refs, ref)
    names = Map.delete(messengers, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp create_messenger(messenger, {messengers, messengers_refs}) do
    {:ok, pid} = Adapter.MessengersSupervisor.start_new_messenger(messenger)
    ref = Process.monitor(pid)
    mssngr = %{pid: pid, refs: %{}, names: %{}}
    messengers_refs = Map.put(messengers_refs, ref, messenger)
    messengers = Map.put(messengers, messenger, mssngr)
    {messengers, messengers_refs}
  end

  defp create_bot({messengers, messenger}, {name, token}) do
    {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger, token)
    ref = Process.monitor(pid)
    new_refs = get_refs(messengers, messenger)
    new_names = get_names(messengers, messenger)
    messengers = put_in(messengers, [messenger, :refs], Map.put(new_refs, ref, name))
    put_in(messengers, [messenger, :names], Map.put(new_names, name, pid))
  end

  defp get_names(map, key) do
    get_in(map, [key, :names])
  end

  defp get_refs(map, key) do
    get_in(map, [key, :refs])
  end
end