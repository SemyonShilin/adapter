defmodule Adapter.Registry do
  @moduledoc "Модуль для реестра процессов"

  #  Adapter.Registry.create(Adapter.Registry, :telegram, {:bot_2, "TOKEN2"})
  #  Adapter.Registry.lookup(Adapter.Registry, {:telegram, :bot_2})
  #  GenServer.call(Adapter.Registry, {:create, :telegram})
  #  Adapter.Registry.create(Adapter.Registry, {:telegram, :bot_2})
  #  m = Adapter.Schema.Messenger.create("first m")
  #  b = Adapter.Schema.Messenger.add_bot(m, %{name: "bot", token: "TOKEN1"})
  #  Adapter.Repo.all(Adapter.Schema.Bot)

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
    {messengers, messengers_refs} = up_init_tree({%{}, %{}})
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
    messenger = Adapter.Schema.Messenger.create(messenger)
    up_messenger(messenger, {messengers, messengers_refs})
  end

  defp create_bot({messengers, messenger}, {name, token}) do
    messenger = Adapter.Schema.Messenger.find_by_name(messenger)
    bot = Adapter.Schema.Messenger.add_bot(messenger, %{name: name, token: token})
    up_bot({messengers, messenger}, {bot.name, bot.token})
  end

  defp up_messenger(messenger, {messengers, messengers_refs}) do
    if Map.has_key?(messengers, messenger) do
      {messengers, messengers_refs}
    else
      {:ok, pid} = Adapter.MessengersSupervisor.start_new_messenger(messenger)
      ref = Process.monitor(pid)
      mssngr = %{pid: pid, refs: %{}, names: %{}}
      messengers_refs = Map.put(messengers_refs, ref, messenger)
      messengers = Map.put(messengers, messenger, mssngr)
      {messengers, messengers_refs}
    end
  end

  defp up_bot({messengers, messenger}, {name, token}) do
    {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger, token)
    ref = Process.monitor(pid)
    new_refs = get_refs(messengers, messenger)
    new_names = get_names(messengers, messenger)
    messengers = put_in(messengers, [messenger, :refs], Map.put(new_refs, ref, name))
    put_in(messengers, [messenger, :names], Map.put(new_names, name, pid))
  end

  defp up_bot({messenger, name, token}, {messengers, messengers_refs}) do
    {messengers, messengers_refs} = up_messenger(messenger, {messengers, messengers_refs})
    current_messenger_pid = Map.get(messengers, messenger).pid
    {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger, token, current_messenger_pid)
    ref = Process.monitor(pid)
    new_refs = get_refs(messengers, messenger)
    new_names = get_names(messengers, messenger)
    messengers = put_in(messengers, [messenger, :refs], Map.put(new_refs, ref, name))
    messengers = put_in(messengers, [messenger, :names], Map.put(new_names, name, pid))
    {messengers, messengers_refs}
  end

  defp get_names(map, key) do
    get_in(map, [key, :names])
  end

  defp get_refs(map, key) do
    get_in(map, [key, :refs])
  end

  defp up_init_tree({messengers, messengers_refs} = state) do
    new_state = {}
    Adapter.Repo.all(Adapter.Schema.Messenger)
    |> Enum.map(fn(messenger) ->
      Adapter.Schema.Bot.where_messenger(messenger.id) |> up_bots(state)
    end)
    |> List.first
  end

  defp up_bots([bot | other_bots], {messengers, messengers_refs} = state) do
    {new_messengers, new_messengers_refs} = up_bot({bot.messenger.name, bot.name, bot.token}, state)
    messengers = Map.merge(messengers, new_messengers)
    messengers_refs = Map.merge(messengers_refs, new_messengers_refs)
    state = {messengers, messengers_refs}
    up_bots(other_bots, state)
  end

  defp up_bots([], state) do
    state
  end
end