defmodule Adapter.Registry.Client.Async do
  @moduledoc """
    Asynchronous client Registry functions
  """

  defmacro __using__(_opts) do
    quote do
      @name Adapter.Registry

      def async_create(messenger, {bot_uid, token}) do
        GenServer.cast(@name, {:create, messenger, {bot_uid, token}})
      end

      def async_up({kind, uid}) when kind in [:messenger, :bot] do
        GenServer.cast(@name, {:up, kind, uid})
      end

      def async_down({kind, uid}) when kind in [:messenger, :bot] do
        GenServer.cast(@name, {:down, kind, uid})
      end

      def async_delete({kind, uid}) when kind in [:messenger, :bot] do
        GenServer.cast(@name, {:delete, kind, uid})
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
    end
  end
end
