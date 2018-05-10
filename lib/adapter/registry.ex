defmodule Adapter.Registry do
  @moduledoc "Модуль для реестра процессов"

  #  Adapter.Registry.create(Adapter.Registry, :telegram, {:bot_2, "TOKEN2"})
  #  Adapter.Registry.lookup(Adapter.Registry, {:telegram, :bot_2})
  #  GenServer.call(Adapter.Registry, {:create, :telegram})
  #  Adapter.Registry.create(Adapter.Registry, {:telegram, :bot_2})
  #  m = Adapter.Schema.Messenger.create("first m")
  #  m = Adapter.Schema.Messenger |> Adapter.Repo.get_by(name: "telegram")
  #  b = Adapter.Schema.Messenger.add_bot(m, %{name: "bot", token: "TOKEN1"})
  #  Adapter.Repo.all(Adapter.Schema.Bot)

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
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
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    if Map.has_key?(names, name) do
      {:reply, Map.fetch(names, name), state}
    else
      {:reply, "#{name} isn't up" |> String.capitalize, state}
    end
  end

  def handle_call({:create, messenger}, _from, {names, _} = state) do
    if Map.has_key?(names, messenger) do
      {:reply, Map.fetch(names, messenger), state}
    else
      new_state = create_messenger(messenger, state)
      {:reply, new_state, new_state}
    end
  end

  def handle_cast({:create, messenger, {name, token}}, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        {:noreply, Map.fetch(names, name)}
      else
        messengers = create_bot({names, messenger}, {name, token})
        {:noreply, {messengers, refs}}
      end
    else
      {names, refs} = create_messenger(messenger, state)
      names = create_bot({names, messenger}, {name, token})
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs} = state) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)

    messenger = Adapter.Schema.Messenger |> Adapter.Repo.get_by(name: name)
    {names, refs} =
      case messenger do
        %Adapter.Schema.Messenger{} -> up_messenger(messenger.name, {names, refs})
        nil -> {names, refs}
      end

    bot = Adapter.Schema.Bot.get_by_with_messenger(name: name)
    {names, refs} =
      case bot do
        %Adapter.Schema.Bot{} -> up_bot({bot.messenger.name, name, bot.token}, {names, refs})
        nil -> {names, refs}
      end

    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp create_messenger(messenger, {names, refs}) do
    messenger = Adapter.Schema.Messenger.create(messenger)
    up_messenger(messenger.name, {names, refs})
  end

  defp create_bot({messengers, messenger}, {name, token}) do
    messenger = Adapter.Schema.Messenger.find_by_name(messenger)
    bot = Adapter.Schema.Messenger.add_bot(messenger, %{name: name, token: token})
    up_bot({messengers, messenger}, {bot.name, bot.token})
  end

  defp up_messenger(messenger, {names, refs}) do
    if Map.has_key?(names, messenger) do
      {names, refs}
    else
      {:ok, pid} = Adapter.MessengersSupervisor.start_new_messenger(messenger)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, messenger)
      names = Map.put(names, messenger, pid)
      {names, refs}
    end
  end

  defp up_bot({messenger, name, token}, {names, refs}) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        {names, refs}
      else
        messenger_pid = Map.get(names, messenger)
        {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger, token, messenger_pid)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        {names, refs}
      end
    else
      {names, refs} = up_messenger(messenger, {names, refs})
      messenger_pid = Map.get(names, messenger)
      {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger, token, messenger_pid)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {names, refs}
    end
  end

  defp up_init_tree({names, refs} = state) do
    new_state = {}
    Adapter.Repo.all(Adapter.Schema.Messenger)
    |> Enum.map(fn(messenger) ->
      Adapter.Schema.Bot.where_messenger(messenger.id) |> up_bots(state)
    end)
    |> List.first
  end

  defp up_bots([bot | other_bots], {names, refs} = state) do
    state = up_bot({bot.messenger.name, bot.name, bot.token}, state)
    up_bots(other_bots, state)
  end

  defp up_bots([], state), do: state
end