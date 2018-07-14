def Hub.Client do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts.args, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def call() do
    GenServer.call(__MODULE__, {})
  end
end
