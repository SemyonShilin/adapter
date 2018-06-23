defmodule Adapter.Telegram do
  alias Agala.BotParams
  alias Adapter.Telegram.MessageSender
  use Agala.Provider.Telegram, :handler

  use GenServer

  @certificate Application.get_env(:agala_telegram, :certificate)
  @url         Application.get_env(:agala_telegram, :url)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
#    set_webhook(opts)
    {:ok, opts}
  end

  def set_webhook(%BotParams{name: bot_name, provider_params: %{token: token}} = params) do
    conn = %Agala.Conn{request_bot_params: params} |> Agala.Conn.send_to(bot_name)

    HTTPoison.post(
      set_webhook_url(conn),
      webhook_upload_body(conn) ,
      [{"Content-Type", "application/json"}]
    )
    |> parse_body
  end

  def base_url(conn) do
    "https://api.telegram.org/bot" <> conn.request_bot_params.provider_params.token
  end

  def set_webhook_url(conn) do
    base_url(conn) <> "/setWebhook"
  end

  def handle_cast(:post_message, state)  do
    Agala.Bot.Handler.handle(state)

    {:noreply, state}
  end

  def handle_cast({:post_message, message}, state) do
    IO.inspect message
    Agala.Bot.Handler.handle(message, state)

    {:noreply, state}
  end

  defp create_body(map, opts) when is_map(map) do
    Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
  end

  defp create_body_multipart(map, opts) when is_map(map) do
    multipart =
      create_body(map, opts)
      |> Enum.map(fn
        {key, {:file, file}} -> {:file, file, {"form-data", [{:name, key}, {:filename, Path.basename(file)}]}, []}
        {key, value} -> {to_string(key), to_string(value)}
      end)
    {:multipart, multipart}
  end

  defp webhook_upload_body(conn, opts \\ []),
     do: create_body_multipart(%{certificate: {:file, @certificate},
                                 url: server_webhook_url(conn)}, opts)

  defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}),
     do: {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}

  defp parse_body(default), do: default

  defp server_webhook_url(conn),
    do: @url <> conn.request_bot_params.provider_params.token
end