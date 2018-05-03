defmodule Adapter do
  use Application

  def start(_type, _args) do
    Envy.auto_load
#    Adapter.MessengerSupervisor.start_link(name: Adapter.MessengerSupervisor)#(name: :telegram)
#     Adapter.MessengersSupervisor.start_link()
    Adapter.GeneralSupervisor.start_link()
  end
end
