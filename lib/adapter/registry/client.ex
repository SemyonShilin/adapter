defmodule Adapter.Registry.Client do
  @moduledoc """
    Methods of the client side of the registry
  """

  @name Adapter.Registry

  defmacro __using__(_opts) do
    quote do
      use Adapter.Registry.Client.Async
      use Adapter.Registry.Client.Sync
    end
  end
end
