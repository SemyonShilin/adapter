defmodule Adapter.Instance do
  @moduledoc false

  use Export.Ruby

  def new do
    %{adapter: ruby_adapt(),
      listening: ruby_listening()}
  end

  def new(:adapter) do
    ruby_adapt()
  end

  def new(:listening) do
    ruby_listening()
  end

  def ruby_adapt do
    {:ok, pid} = Ruby.start(ruby_lib: Path.expand("priv/bots/telegram_bot_template/lib"))
    pid
  end

  def ruby_listening do
    {:ok, pid} = Ruby.start(ruby_lib: Path.expand("priv/bots/telegram_bot_template/lib"))
    pid
  end
end
