defmodule Adapter.Registry do
  @moduledoc """
    Модуль для реестра процессов
    Команды:
      1) Работа с реестром
         Adapter.Registry.create("telegram", {"bot_1", "TOKEN"})
         Adapter.Registry.lookup("telegram")
         Adapter.Registry.down({:messenger, "telegram"})
         Adapter.Registry.down({:bot,A "bot"})
      2) Работа с бд
         m = Adapter.Messengers.create("telegram")
         m = Adapter.Messengers.get_by_messenger("telegram")
         b = Adapter.Messengers.add_bot(m, %{uid: "bot", token: "TOKEN", state: "up"})
         Adapter.Repo.all(Adapter.Schema.Bot)
         Adapter.Messengers.Messenger |> Adapter.Repo.delete_all
         Adapter.Bots.Bot |> Adapter.Repo.delete_all
      3) Отправка сообщений пользователю
         Adapter.Registry.post_message("bot", "json")

  """

  use GenServer
  import Adapter.Registry.Helpers

  @name Adapter.Registry

  def start_link(opts) do
    GenServer.start_link(@name, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end

  def lookup do
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

  def post_message(bot_uid, hub, message) do
    GenServer.cast(@name, {:message, bot_uid, hub, message})
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
      {:reply, "#{name} isn't up" |> String.capitalize(), state}
    end
  end

  @impl true
  def handle_call({:create, messenger}, _from, {names, _} = state) do
    if Map.has_key?(names, messenger) do
      {:reply, {messenger, Map.get(names, messenger)}, state}
    else
      case create_messenger(messenger, state) do
        {_, _} = new_state ->
          {:reply, {messenger, Map.get(elem(new_state, 0), messenger)}, new_state}

        other ->
          {:reply, other, state}
      end
    end
  end

  @impl true
  def handle_call({:create, messenger, {name, token}}, _from, {names, refs} = state) do
    if Map.has_key?(names, messenger) do
      if Map.has_key?(names, name) do
        {:reply, {name, Map.get(names, name)}, state}
      else
        case create_bot({messenger, name, token}, state) do
          {_, _} = new_state -> {:reply, {name, Map.get(elem(new_state, 0), name)}, new_state}
          other -> {:reply, other, state}
        end
      end
    else
      case create_messenger(messenger, state) do
        {names, refs} = _ ->
          case create_bot({messenger, name, token}, state) do
            {_, _} = new_state -> {:reply, {name, Map.get(elem(new_state, 0), name)}, new_state}
            other -> {:reply, other, state}
          end

        other ->
          up_messenger(messenger, {names, refs})

          case create_bot({messenger, name, token}, state) do
            {_, _} = new_state -> {:reply, {name, Map.get(elem(new_state, 0), name)}, new_state}
            other -> {:reply, other, state}
          end
      end
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
    if Map.has_key?(names, name) do
      new_state =
        name
        |> Adapter.Messengers.pluck_bots_uid_for()
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)

      {:reply, name, new_state}
    else
      {:reply, name, state}
    end
  end

  @impl true
  def handle_call({:down, :bot, name}, _from, {names, _} = state) do
    if Map.has_key?(names, name) do
      nesw_state = down_tree(name, :bot, state)
      {:reply, name, nesw_state}
    else
      {:reply, name, state}
    end
  end

  @impl true
  def handle_call({:delete, :messenger, name}, _from, {names, _} = state) do
    if Map.has_key?(names, name) do
      new_state =
        name
        |> Adapter.Messengers.pluck_bots_uid_for()
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)
      Adapter.Messengers.delete(name)

      {:reply, :ok, new_state}
    else
      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:delete, :bot, uid}, _from, {names, _} = state) do
    if Map.has_key?(names, uid) do
      new_state = down_tree(uid, :bot, state)
      Adapter.Bots.delete(uid)

      {:reply, :ok, new_state}
    else
      {:reply, :ok, state}
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
    if Map.has_key?(names, name) do
      new_state =
        name
        |> Adapter.Messengers.pluck_bots_uid_for()
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:down, :bot, name}, {names, _} = state) do
    if Map.has_key?(names, name) do
      {:noreply, down_tree(name, :bot, state)}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:delete, :messenger, name}, {names, _} = state) do
    if Map.has_key?(names, name) do
      new_state =
        name
        |> Adapter.Messengers.pluck_bots_uid_for()
        |> down_tree(:bot, state)

      new_state = down_tree(name, :messenger, new_state)
      Adapter.Messengers.delete(name)

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:delete, :bot, uid}, {names, _} = state) do
    if Map.has_key?(names, uid) do
      new_state = down_tree(uid, :bot, state)
      Adapter.Bots.delete(uid)

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:message, bot, hub, message}, {names, _} = state) do
    if Map.has_key?(names, bot) do
      bot = Adapter.Bots.get_by_with_messenger(uid: bot)

      Module.concat(Engine, String.capitalize(bot.messenger.name)).message_pass(
        bot.uid,
        hub,
        message
      )

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:message, bot, message}, {names, _} = state) do
    if Map.has_key?(names, bot) do
      bot = Adapter.Bots.get_by_with_messenger(uid: bot)

      Module.concat(Engine, String.capitalize(bot.messenger.name)).message_pass(bot.uid, message)

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
  def handle_info({:DOWN, _ref, :process, _pid, :kill}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_msg, state) do
    {:noreply, state}
  end
end
