defmodule Adapter do
  use Application

  def start(_type, _args) do
#    Adapter.BotPid.start_link(:listening)
#    Adapter.BotPid.start_link(:adapter)
    Adapter.Supervisor.start_link()
  end
end
