defmodule Hub.Client.Consumer do
  require Logger
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, rabbitmq_connect()}
  end

  def handle_info({:basic_deliver, payload, meta} , state) do
    Logger.info(fn -> "Received message" end)

    #TODO: change last bot to bot find by uid
    bot =
      Adapter.Bots.Bot
      |> Adapter.Repo.all
      |> List.last()

    Adapter.Registry.post_message(bot.uid, true, Poison.decode!(payload))

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_msg, state) do
    AMQP.Connection.close(state.connection)

    {:noreply, state}
  end

  def rabbitmq_connect do
    case AMQP.Connection.open(port: 5672) do
      {:ok, connection} ->
        Process.monitor(connection.pid)
        {:ok, channel} = AMQP.Channel.open(connection)
        AMQP.Queue.declare(channel, "hub_queue")
        AMQP.Basic.consume(channel, "hub_queue", nil, no_ack: true)
        %{channel: channel, connection: connection}
      {:error, _} ->
        :timer.sleep(10000)
        rabbitmq_connect()
    end
  end
end