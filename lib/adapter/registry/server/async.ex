defmodule Adapter.Registry.Server.Async do
  @moduledoc """
    Asynchronous server Registry hanlders
  """

  defmacro __using__(_opts) do
    quote do
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

          Module.concat(Engine, String.capitalize(bot.messenger.name)).message_pass(bot.uid, hub, message)

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
  end
end
