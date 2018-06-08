defmodule Adapter.Registry.Server do
  @moduledoc false

  import Adapter.Registry.Helpers

  @doc """
    Sync callbacks
  """

  defmacro __using__(_opts) do
    quote do
      @name Adapter.Registry

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
          find_pid = &(if String.starts_with?("#{elem(&1, 0)}", "listener"), do: elem(&1, 0))
          bot = Adapter.Bots.get_by_bot(uid: bot)
          tuple = if System.get_env("BOT_ENV") == "development", do: {:post_message, message}, else: {:post_message_forward, bot.token, message}

          Map.get(names, bot)
          |> Supervisor.which_children()
          |> Enum.find_value(find_pid)
          |> GenServer.cast(tuple)
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
    end
  end
end
