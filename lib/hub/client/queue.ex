defmodule Hub.Client.Queue do
  @moduledoc false

  use Hub.Client.Base
  alias AMQP.{Connection, Basic, Channel, Queue}

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
    Connection.close(state.connection)

    {:noreply, state}
  end

  def call_hub(%{message: message, state: state}) do
    Basic.publish state.channel, "", "adapter_queue", Poison.encode!(message)

    %{"data" => []}
  end

  def rabbitmq_connect do
    case Connection.open(Application.get_env(:adapter, :rabbitmq)) do
      {:ok, connection} ->
        Process.monitor(connection.pid)
        {:ok, channel} = Channel.open(connection)
        Queue.declare(channel, "adapter_queue")
        %{channel: channel, connection: connection}
      {:error, _} ->
        :timer.sleep(100)
        rabbitmq_connect()
    end
  end
end
