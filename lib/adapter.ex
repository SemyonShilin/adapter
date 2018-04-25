defmodule Adapter do
  use Application

  def start(_type, _args) do
    Adapter.BotPid.start_link(:listening)
  end
end
