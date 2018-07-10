defmodule Adapter.Viber.Helpers do
  @moduledoc """

  """

  alias Adapter.Viber.Conn.Response
  @base_url "https://chatapi.viber.com/pa"

  @spec send_message(conn :: Agala.Conn.t, message :: String.t, opts :: Enum.t) :: Agala.Conn.t
  def send_message(conn, chat_id, message, opts \\ []) do
    Map.put(conn, :response, %Response{
      method: :post,
      payload: %{
        url: base_url("/send_message"),
        body: create_body(message, opts),
        headers: [
          {"X-Viber-Auth-Token", to_string(conn.request_bot_params.provider_params.token)},
          {"Content-Type", "application/json"}
        ]
      }
    })
  end

  defp base_url(route),
       do: fn (_token)-> @base_url <> route end

  defp create_body(map, opts) when is_map(map) do
    Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
  end
end