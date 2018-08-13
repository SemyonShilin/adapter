defmodule Adapter.Registry.Client.Sync do
  @moduledoc """
    Synchronous client Registry functions
  """

  defmacro __using__(_opts) do
    quote do
      @name Adapter.Registry

      def lookup do
        GenServer.call(@name, :lookup)
      end

      def lookup(uid) do
        GenServer.call(@name, {:lookup, uid})
      end

      def create(messenger, {bot_uid, token}) do
        GenServer.call(@name, {:create, messenger, {bot_uid, token}})
      end

      def create(messenger) do
        GenServer.call(@name, {:create, messenger})
      end

      def up({kind, uid}) when kind in [:messenger, :bot] do
        GenServer.call(@name, {:up, kind, uid})
      end

      def down({kind, name}) when kind in [:messenger, :bot] do
        GenServer.call(@name, {:down, kind, name})
      end

      def delete({kind, uid}) when kind in [:messenger, :bot] do
        GenServer.call(@name, {:delete, kind, uid})
      end
    end
  end
end
