defmodule Hub.Client do
  @moduledoc false

  use Supervisor
  alias Hub.Client.{HTTP, TCP, Queue, Consumer}

  def start_link(_args \\ []) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      {HTTP, %{}},
      {TCP, %{}},
#      {Queue, %{}},
#      {Consumer, %{}},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
