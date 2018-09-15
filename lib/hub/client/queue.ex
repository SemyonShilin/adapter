defmodule Hub.Client.Queue do
  @moduledoc false

  use Hub.Client.Base

  def init(_args) do
    {:ok, rabbitmq_connect()}
  end

  def call(%{} = message) do
    GenServer.call(__MODULE__, message)
  end

  def handle_info({:basic_deliver, payload, meta} , state) do
    Logger.info(fn -> "Received message" end)

    Hub.MessageHandler.Producer.publish(payload)

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_call(%{} = message, _from, state) do
    {:reply, call_hub(%{message: message, state: state}), state}
  end

  def terminate(_msg, state) do
    AMQP.Connection.close(state.connection)

    {:noreply, state}
  end

  def call_hub(%{message: message, state: state}) do
    AMQP.Basic.publish state.channel, "", "adapter_queue", Poison.encode!(message)

    %{"data" => []}
  end

  def rabbitmq_connect do
    case AMQP.Connection.open(port: 5672) do
      {:ok, connection} ->
        Process.monitor(connection.pid)
        {:ok, channel} = AMQP.Channel.open(connection)
        AMQP.Queue.declare(channel, "adapter_queue")
        %{channel: channel, connection: connection}
      {:error, _} ->
        :timer.sleep(10000)
        rabbitmq_connect()
    end
  end
end
