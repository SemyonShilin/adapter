defmodule Adapter.Registry do
  @moduledoc """
    Модуль для реестра процессов
    Команды:
      1) Работа с реестром
         Adapter.Registry.create("telegram", {"bot_1", "390126265:AAGokHwWau7N7sd9Vga0g_qE3-Th9gNcXME"})
         Adapter.Registry.lookup("telegram")
         Adapter.Registry.down({:messenger, "telegram"})
         Adapter.Registry.down({:bot,A "bot"})
      2) Работа с бд
         m = Adapter.Messengers.create("telegram")
         m = Adapter.Messengers.get_by_messenger("telegram")
         b = Adapter.Messengers.add_bot(m, %{uid: "bot", token: "TOKEN1"})
         Adapter.Repo.all(Adapter.Schema.Bot)
         Adapter.Messengers.Messenger |> Adapter.Repo.delete_all
         Adapter.Bots.Bot |> Adapter.Repo.delete_all
      3) Отправка сообщений пользователю
         Adapter.Registry.post_message("bot", "json")

  """

  use GenServer
  @name Adapter.Registry

  def start_link(opts) do
    GenServer.start_link(@name, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end

  def lookup() do
    GenServer.call(@name, :lookup)
  end

  def lookup(uid) do
    GenServer.call(@name, {:lookup, uid})
  end

  def async_create(messenger, {bot_uid, token}) do
    GenServer.cast(@name, {:create, messenger, {bot_uid, token}})
  end

  def create(messenger, {bot_uid, token}) do
    GenServer.call(@name, {:create, messenger, {bot_uid, token}})
  end

  def create(messenger) do
    GenServer.call(@name, {:create, messenger})
  end

  def async_up({kind, uid}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:up, kind, uid})
  end

  def up({kind, uid}) when kind in [:messenger, :bot] do
    GenServer.call(@name, {:up, kind, uid})
  end

  def async_down({kind, uid}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:down, kind, uid})
  end

  def down({kind, name}) when kind in [:messenger, :bot] do
    GenServer.call(@name, {:down, kind, name})
  end

  def async_delete({kind, uid}) when kind in [:messenger, :bot] do
    GenServer.cast(@name, {:delete, kind, uid})
  end

  def delete({kind, uid}) when kind in [:messenger, :bot] do
    GenServer.call(@name, {:delete, kind, uid})
  end

  def post_message(bot_uid, message) do
    GenServer.cast(@name, {:message, bot_uid, message})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  @impl true
  def handle_call(:lookup, _from, {names, _} = state) do
    {:reply, names, state}
  end

  @impl true
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    if Map.has_key?(names, name) do
      {:reply, Map.fetch(names, name), state}
    else
      {:reply, "#{name} isn't up" |> String.capitalize, state}
    end
  end

  @impl true
  def handle_call({:create, messenger}, _from, {names, _} = state) do
    if Map.has_key?(names, messenger) do
      {:reply, {messenger, Map.get(names, messenger)}, state}
    else
      new_state = create_messenger(messenger, state)
      {:reply, {messenger, Map.get(elem(new_state, 0), messenger)}, new_state}
    end
  end

  @impl true
  def handle_call({:create, messenger, {name, token}}, _from, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        {:reply, {name, Map.get(names, name)}, state}
      else
        new_state = create_bot({messenger, name, token}, state)
        {:reply, {name, Map.get(elem(new_state, 0), name)}, new_state}
      end
    else
      {names, refs} = create_messenger(messenger, state)
      new_state = create_bot({messenger, name, token}, {names, refs})
      {:reply, {name, Map.get(elem(new_state, 0), name)}, new_state}
    end
  end

  @impl true
  def handle_call({:up, :messenger, name}, _from, state) do
    new_state = up_messenger(name, state)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:up, :bot, uid}, _from, state) do
    bot = Adapter.Bots.get_by_with_messenger(uid: uid)
    new_state = up_bot({bot.messenger.name, uid, bot.token}, state)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:down, :messenger, name}, _from, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:reply, name, state}
    else
      new_state =
        Adapter.Messengers.pluck_bots_uid_for(name)
        |> down_tree(:bot, state)
      new_state = down_tree(name, :messenger, new_state)

      {:reply, name, new_state}
    end
  end

  @impl true
  def handle_call({:down, :bot, name}, _from, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:reply, name, state}
    else
      nesw_state = down_tree(name, :bot, state)
      {:reply, name, nesw_state}
    end
  end

  @impl true
  def handle_call({:delete, :messenger, name}, _from, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:reply, :ok, state}
    else
      new_state =
        Adapter.Messengers.pluck_bots_uid_for(name)
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)
      Adapter.Messengers.delete(name)

      {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_call({:delete, :bot, uid}, _from, {names, _} = state) do
    if !Map.has_key?(names, uid) do
      {:reply, :ok, state}
    else
      new_state = down_tree(uid, :bot, state)
      Adapter.Bots.delete(uid)

      {:reply, :ok, new_state}
    end
  end

  @doc """
    Async callbacks
  """

  @impl true
  def handle_cast({:create, messenger, {name, token}}, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        {:noreply, Map.fetch(names, name)}
      else
        new_state = create_bot({messenger, name, token}, state)
        {:noreply, new_state}
      end
    else
      {names, refs} = create_messenger(messenger, state)
      new_state = create_bot({messenger, name, token}, {names, refs})
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast({:up, :messenger, name}, state) do
    {:noreply, up_messenger(name, state)}
  end

  @impl true
  def handle_cast({:up, :bot, uid}, state) do
    bot = Adapter.Bots.get_by_with_messenger(uid: uid)
    new_state = up_bot({bot.messenger.name, uid, bot.token}, state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:down, :messenger, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      new_state =
        Adapter.Messengers.pluck_bots_uid_for(name)
        |> down_tree(:bot, state)
      new_state = down_tree(name, :messenger, new_state)

      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast({:down, :bot, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:noreply, down_tree(name, :bot, state)}
    end
  end

  @impl true
  def handle_cast({:delete, :messenger, name}, {names, _} = state) do
    if !Map.has_key?(names, name) do
      {:noreply, state}
    else
      new_state =
        Adapter.Messengers.pluck_bots_uid_for(name)
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)
      Adapter.Messengers.delete(name)

      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast({:delete, :bot, uid}, {names, _} = state) do
    if !Map.has_key?(names, uid) do
      {:noreply, state}
    else
      new_state = down_tree(uid, :bot, state)
      Adapter.Bots.delete(uid)

      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast({:message, bot, message}, {names, _} = state) do
    if Map.has_key?(names, bot) do
      bot = Adapter.Bots.get_by_bot(uid: bot)
      IO.inspect names
      Map.get(names, bot.uid)
      |> Supervisor.which_children()
      |> IO.inspect
      |> List.first
      |> GenServer.cast({:post_message, message})
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)

    messenger = Adapter.Messengers.find_by_atts(%{name: name, state: "up"})
    {names, refs} =
      case messenger do
        %Adapter.Messengers.Messenger{} -> up_messenger(messenger.name, {names, refs})
        nil -> {names, refs}
      end

    bot = Adapter.Bots.get_by_with_messenger(%{uid: name, state: "up"})
    {names, refs} =
      case bot do
        %Adapter.Bots.Bot{} -> up_bot({bot.messenger.name, name, bot.token}, {names, refs})
        nil -> {names, refs}
      end

    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, :kill}, state) do
    IO.inspect "KILL!!!!!!!!"
    IO.inspect state
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    IO.inspect "LAST4232523525235"
    IO.inspect state
    IO.inspect  _msg
    {:noreply, state}
  end

  @impl true
  def terminate(_msg, state) do
    IO.inspect "terminate222222"
    IO.inspect state
    IO.inspect  _msg
    {:noreply, state}
  end

  def create_messenger(messenger, {names, refs}) do
    messenger = Adapter.Messengers.create(messenger)
    up_messenger(messenger.name, {names, refs})
  end

  def create_bot({messenger_name, bot_uid, token}, state) do
    messenger = Adapter.Messengers.get_by_messenger(messenger_name)
    bot = Adapter.Messengers.add_bot(messenger, %{uid: bot_uid, token: token})
    up_bot({messenger_name, bot.uid, bot.token}, state)
  end

  def up_messenger(messenger, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      state
    else
      {:ok, pid} = Adapter.MessengersSupervisor.start_new_messenger()
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, messenger)
      names = Map.put(names, messenger, pid)
      Adapter.Messengers.set_up_messenger(messenger)

      {names, refs}
    end
  end

  def up_bot({messenger, name, token}, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        state
      else
        messenger_pid = Map.get(names, messenger)
        {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, {messenger, name, token})
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        Adapter.Bots.set_up_bot(name)

        {names, refs}
      end
    else
      {names, refs} = up_messenger(messenger, state)
      messenger_pid = Map.get(names, messenger)
      {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, {messenger, name, token})
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      Adapter.Bots.set_up_bot(name)

      {names, refs}
    end
  end

  def up_init_tree(state) do
    Adapter.Messengers.list_up_messengers()
    |> Enum.map(fn(messenger) ->
      Adapter.Bots.where_messenger(messenger.id) |> up_bots(state)
    end)
    |> Enum.reduce({%{}, %{}}, fn(tuple, acc) ->
      {Map.merge(elem(tuple, 0), elem(acc, 0)),
        Map.merge(elem(tuple, 1), elem(acc, 1))}
    end)
  end

  def up_bots([bot | other_bots], state) do
    state = up_bot({bot.messenger.name, bot.uid, bot.token}, state)
    up_bots(other_bots, state)
  end

  def up_bots([], state), do: state

  def down_tree(name, kind, state) when is_bitstring(name) do
    {pid, new_state} = delete_from_state(name, state)
    stop_process(kind, pid, name)
    new_state
  end

  def down_tree([name | tail] = names, kind, state) when is_list(names) do
    {pid, new_state} = delete_from_state(name, state)
    stop_process(kind, pid, name)
    down_tree(tail, kind, new_state)
  end

  def down_tree([], _, state), do: state

  def delete_from_state(name, {names, refs})  do
    ref = Enum.find_value(refs, fn(elem) ->
      if elem(elem, 1) == name, do: elem(elem, 0)
    end)
    Process.demonitor(ref)
    {name, refs} = Map.pop(refs, ref)
    pid = Map.get(names, name)
    names = Map.delete(names, name)
    Adapter.Messengers.set_down_messenger_tree(name)
    Adapter.Bots.set_down_bot(name)

    {pid, {names, refs}}
  end

  def stop_process(:bot, pid, name), do: Adapter.MessengerSupervisor.stop(pid, name)

  def stop_process(:messenger, pid, _name), do: Adapter.MessengersSupervisor.stop(pid)
end
