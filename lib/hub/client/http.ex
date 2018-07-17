defmodule Hub.Client.HTTP do
  @moduledoc false

  @http_client Application.get_env(:adapter, Hub.Client.HTTP)
  @headers     [{"Content-Type", "application/json"}]

  use Hub.Client.Base

  def init(_args) do
    HTTPoison.start
  end

  def call(message = %{}) do
    GenServer.call(__MODULE__, message)
  end

  def handle_call(message = %{}, _from, state) do
    {:reply, call_hub(message), state}
  end

  def call_hub(message) do
    with {:ok, %HTTPoison.Response{body: body}} =
           HTTPoison.post(
             hub_post_url(),
             Poison.encode!(message),
             @headers
           ) do
      decode(body)
    end
  end

  defp hub_post_url do
    case Keyword.get(@http_client, :hub_post) do
      url when is_bitstring(url) -> url
      :env -> System.get_env("HUB_POST")
      _ -> ""
    end
  end
end
