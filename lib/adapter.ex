defmodule Adapter do
  use Application

  def start(_type, _args) do
    Adapter.Supervisor.start_link()
  end
end
