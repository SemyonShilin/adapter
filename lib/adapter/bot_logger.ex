defmodule Adapter.BotLogger do
  @moduledoc false
  require Logger

  @adapter Application.get_env(:adapter, Adapter.BotLogger)

  def debug(message) do
    @adapter
    |> Keyword.get(:type)
    |> debug(message)
  end

  def info(message) do
    @adapter
    |> Keyword.get(:type)
    |> info(message)
  end

  defp debug(:console, message) do
    Logger.debug fn -> "----> #{message} <----" end
  end

  defp info(:console, message) do
    Logger.info fn -> "----> #{message} <----" end
  end

  defp debug(:file, _message) do
  end

  defp info(:file, _message) do
  end
end
