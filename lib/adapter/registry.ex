defmodule Adapter.Registry do
  @moduledoc """
    Модуль для реестра процессов
    Команды:
      1) Работа с реестром
         Adapter.Registry.create("telegram", {"bot_3", "TOKEN3"})
         Adapter.Registry.lookup("telegram")
         Adapter.Registry.down({:messenger, "telegram"})
         Adapter.Registry.down({:bot, "bot"})
      2) Работа с бд
         m = Adapter.Schema.Messenger.create("first m")
         m = Adapter.Schema.Messenger |> Adapter.Repo.get_by(name: "telegram")
         b = Adapter.Schema.Messenger.add_bot(m, %{name: "bot", token: "TOKEN1"})
         Adapter.Repo.all(Adapter.Schema.Bot)
      3) Отправка сообщений пользователю
         Adapter.Registry.post_message("bot", "json")

  """

  use GenServer

  @name Adapter.Registry

  def start_link(opts) do
    GenServer.start_link(@name, :ok, opts)
  end

  def lookup() do
    GenServer.call(@name, :lookup)
  end

  def lookup(name) do
    GenServer.call(@name, {:lookup, name})
  end

  def create(messenger, {bot_name, token}) do
    GenServer.cast(@name, {:create, messenger, {bot_name, token}})
  end

  def create(messenger) do
    GenServer.call(@name, {:create, messenger})
  end

  def up({kind, name}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:up, kind, name})
  end

  def delete({kind, name}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:delete, kind, name})
  end

  def down({kind, name}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:down, kind, name})
  end

  def post_message(bot, message) do
    GenServer.cast(@name, {:message, bot, message})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def init(:ok) do
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end

  def handle_call(:lookup, _from, {names, _} = state) do
    {:reply, names, state}
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
        messengers = create_bot({messenger, name, token}, state)
        {:noreply, {messengers, refs}}
      end
    else
      {names, refs} = create_messenger(messenger, state)
      names = create_bot({messenger, name, token}, {names, refs})
      {:noreply, {names, refs}}
    end
  end

  def handle_cast({:up, :messenger, name}, state) do
    {:noreply, up_messenger(name, state)}
  end

  def handle_cast({:up, :bot, name}, state) do
    bot = Adapter.Schema.Bot.get_by_with_messenger(name: name)
    new_state = up_bot({bot.messenger.name, name, bot.token}, state)
    {:noreply, new_state}
  end

  def handle_cast({:delete, :messenger, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      new_state =
        Adapter.Schema.Messenger.pluck_bots_name_for(name)
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)
      Adapter.Schema.Messenger.delete(name)

      {:noreply, new_state}
    end
  end

  def handle_cast({:delete, :bot, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      new_state = down_tree(name, :bot, state)
      Adapter.Schema.Bot.delete(name)

      {:noreply, new_state}
    end
  end

  def handle_cast({:down, :messenger, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      new_state =
        Adapter.Schema.Messenger.pluck_bots_name_for(name)
        |> down_tree(:bot, state)
      new_state = down_tree(name, :messenger, new_state)

      {:noreply, new_state}
    end
  end

  def handle_cast({:down, :bot, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:noreply, down_tree(name, :bot, state)}
    end
  end

  def handle_cast({:message, bot, message}, {names, _} = state) do
    if Map.has_key?(names, bot) do
      find_pid = &(if String.starts_with?("#{elem(&1, 0)}", "listener"), do: elem(&1, 0))
      Map.get(names, bot)
      |> Supervisor.which_children()
      |> Enum.find_value(find_pid)
      |> GenServer.cast({:post_message, message})
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
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

  def handle_info({:DOWN, ref, :process, _pid, :kill}, state) do
    IO.inspect "KILL!!!!!!!!"
    IO.inspect state
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    IO.inspect "LAST4232523525235"
    IO.inspect state
    IO.inspect  _msg
    {:noreply, state}
  end


  def terminate(_msg, state) do
    IO.inspect "terminate222222"
    IO.inspect state
    IO.inspect  _msg
    {:noreply, state}
  end

  defp create_messenger(messenger, {names, refs}) do
    messenger = Adapter.Schema.Messenger.create(messenger)
    up_messenger(messenger.name, {names, refs})
  end

  defp create_bot({messenger_name, name, token}, state) do
    messenger = Adapter.Schema.Messenger.find_by_name(messenger_name)
    bot = Adapter.Schema.Messenger.add_bot(messenger, %{name: name, token: token})
    up_bot({messenger_name, bot.name, bot.token}, state)
  end

  defp up_messenger(messenger, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      state
    else
      {:ok, pid} = Adapter.MessengersSupervisor.start_new_messenger()
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, messenger)
      names = Map.put(names, messenger, pid)
      {names, refs}
    end
  end

  defp up_bot({messenger, name, token}, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        state
      else
        messenger_pid = Map.get(names, messenger)
        {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, token)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        {names, refs}
      end
    else
      {names, refs} = up_messenger(messenger, state)
      messenger_pid = Map.get(names, messenger)
      {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, token)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {names, refs}
    end
  end

  defp up_init_tree(state) do
    Adapter.Repo.all(Adapter.Schema.Messenger)
    |> Enum.map(fn(messenger) ->
      Adapter.Schema.Bot.where_messenger(messenger.id) |> up_bots(state)
    end)
    |> Enum.reduce({%{}, %{}}, fn(tuple, acc) ->
      {Map.merge(elem(tuple, 0), elem(acc, 0)),
       Map.merge(elem(tuple, 1), elem(acc, 1))}
    end)
  end

  defp up_bots([bot | other_bots], state) do
    state = up_bot({bot.messenger.name, bot.name, bot.token}, state)
    up_bots(other_bots, state)
  end

  defp up_bots([], state), do: state

  defp down_tree(name, kind, state) when is_bitstring(name) do
    {pid, new_state} = delete_from_state(name, state)
    stop_process(kind, pid)
    new_state
  end

  defp down_tree([name | tail] = names, kind, state) when is_list(names) do
    {pid, new_state} = delete_from_state(name, state)
    stop_process(kind, pid)
    down_tree(tail, kind, new_state)
  end

  defp down_tree([], _, state), do: state

  defp delete_from_state(name, {names, refs})  do
    ref = Enum.find_value(refs, fn(elem) ->
      if elem(elem, 1) == name, do: elem(elem, 0)
    end)
    Process.demonitor(ref)
    {name, refs} = Map.pop(refs, ref)
    pid = Map.get(names, name)
    names= Map.delete(names, name)

    {pid, {names, refs}}
  end

  defp stop_process(:bot, pid), do: Adapter.MessengerSupervisor.stop(pid)

  defp stop_process(:messenger, pid), do: Adapter.MessengersSupervisor.stop(pid)
end