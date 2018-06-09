defmodule Adapter.Registry.Client do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @name Adapter.Registry

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
    end
  end
end
