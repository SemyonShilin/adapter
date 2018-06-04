defmodule Adapter.Instance do
  @moduledoc false

  use Export.Ruby

  def new do
    %{adapter: ruby_adapter(),
      listening: ruby_listening()}
  end

  def new(:adapter) do
    ruby_adapter()
  end

  def new(:listening) do
    ruby_listening()
  end

  def ruby_adapter do
    {:ok, pid} = Ruby.start(ruby_lib: Path.expand(lib()))
    pid
  end

  def ruby_listening do
    {:ok, pid} = Ruby.start(ruby_lib: Path.expand(lib()))
    pid
  end

  defp lib do
    case Mix.env do
      :dev  -> "priv/bots/tbot/bin"
      :prod -> "priv/bots/telegram_bot_template/lib"
    end
  end
end
