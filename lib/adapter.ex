defmodule Adapter do
  use Application

  def start(_type, _args) do
#    Adapter.BotSupervisor.start_link(name: :bot_1)
    Envy.auto_load
    Adapter.MessengerSupervisor.start_link(name: :telegram)
  end
end
