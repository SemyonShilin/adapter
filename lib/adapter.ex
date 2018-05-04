defmodule Adapter do
  use Application

  def start(_type, _args) do
    Envy.auto_load
    :observer.start
    Adapter.GeneralSupervisor.start_link()
  end
end
