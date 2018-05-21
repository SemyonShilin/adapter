defmodule Adapter.Registry.Helpers do
  @moduledoc false

  @doc """
    Custom methods
  """

  defmacro __using__(_opts) do
    quote do

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
            {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, token)
            ref = Process.monitor(pid)
            refs = Map.put(refs, ref, name)
            names = Map.put(names, name, pid)
            Adapter.Bots.set_up_bot(name)

            {names, refs}
          end
        else
          {names, refs} = up_messenger(messenger, state)
          messenger_pid = Map.get(names, messenger)
          {:ok, pid} = Adapter.MessengerSupervisor.start_new_bot(messenger_pid, token)
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
        stop_process(kind, pid)
        new_state
      end

      def down_tree([name | tail] = names, kind, state) when is_list(names) do
        {pid, new_state} = delete_from_state(name, state)
        stop_process(kind, pid)
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

      def stop_process(:bot, pid), do: Adapter.MessengerSupervisor.stop(pid)

      def stop_process(:messenger, pid), do: Adapter.MessengersSupervisor.stop(pid)
    end
  end
end
