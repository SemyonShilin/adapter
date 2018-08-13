defmodule Adapter.BotLogger do
  @moduledoc false
  require Logger

  @adapter Application.get_env(:adapter, Adapter.BotLogger)
  @on_load :load_config

  def debug(message) do
    Logger.debug fn -> "----> #{message} <----" end
  end

  def info(message) do
    Logger.info fn -> "----> #{message} <----" end
  end

  def load_config do
    case Keyword.get(@adapter, :type) do
      :file ->
        Logger.add_backend {LoggerFileBackend, :info}
        Logger.configure_backend {LoggerFileBackend, :info},
                                 path: "priv/logs/adapter.log"
      :console -> :ok
      _ -> :abort
    end
  end
end
