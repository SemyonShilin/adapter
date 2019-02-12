defmodule Hub.Client.TCP do
  @moduledoc false

  @tcp Application.get_env(:adapter, Hub.Client.TCP) |> Keyword.get(:hub_tcp)

  use Hub.Client.Base

  def init(_args) do
    {:ok, %{}}
  end

  def call(%{} = message) do
    GenServer.call(__MODULE__, message)
  end

  def handle_call(%{} = message, _from, state) do
    {:ok, socket} = conn()
    result = call_hub(socket, message)
    :gen_tcp.close(socket)
    {:reply, result, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_msg, state) do
    {:noreply, state}
  end

  def call_hub(socket, message) do
    socket
    |> send_message(message)
    |> decode()
  end

  defp conn do
    {host, port} = @tcp
    :gen_tcp.connect(host, port, [:binary, active: false, packet: 4])
  end

  defp send_message(socket, message) do
    case :gen_tcp.send(socket, Poison.encode!(message)) do
      :ok -> socket
      {:error, _} -> :error
    end
  end

  defp decode(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        # |> key_to_downcase()
        message |> Poison.decode!()

      {:error, _} ->
        :error
    end
  end

  defp decode(:error), do: :error

  defp key_to_downcase(message) do
    message
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      case v do
        %{} ->
          Map.put(acc, String.downcase(k), key_to_downcase(v))

        _ when is_list(v) ->
          Map.put(acc, String.downcase(k), Enum.map(v, &key_to_downcase(&1)))

        _ ->
          Map.put(acc, String.downcase(k), v)
      end
    end)
  end
end
