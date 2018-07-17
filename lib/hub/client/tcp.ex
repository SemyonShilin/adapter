defmodule Hub.Client.TCP do
  @moduledoc false

  @tcp Application.get_env(:adapter, Hub.Client.TCP) |> Keyword.get(:hub_tcp)

  use Hub.Client.Base

  def init (_args)do
    conn()
  end

  def call(message = %{}) do
    GenServer.call(__MODULE__, message)
  end

  def handle_call(message = %{}, _from, socket) do
    {:reply, call_hub(socket, message), socket}
  end

  def call_hub(socket, message) do
    socket
    |> :gen_tcp.send(Poison.encode!(message))
    |> decode()
  end

  def terminate(_msg, socket) do
    :gen_tcp.close(socket)
    {:ok, new_socket} = conn()

    {:noreply, new_socket}
  end

  defp conn do
    {host, port} = @tcp
    :gen_tcp.connect(host, port, [:binary])
  end
end
