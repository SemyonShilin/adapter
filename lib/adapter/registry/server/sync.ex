defmodule Adapter.Registry.Server.Sync do
  @moduledoc """
    Synchronous server Registry hanlders
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
          case create_messenger(messenger, state) do
            {_, _} = new_state -> {:reply, {messenger, Map.get(elem(new_state, 0), messenger)}, new_state}
            other -> {:reply, other, state}
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
    end
  end
end
