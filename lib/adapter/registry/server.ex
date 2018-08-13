defmodule Adapter.Registry.Server do
  @moduledoc """
    Methods of the server side of the registry
  """

  import Adapter.Registry.Helpers

  defmacro __using__(_opts) do
    quote do
      use Adapter.Registry.Server.Sync
      use Adapter.Registry.Server.Async
    end
  end
end
