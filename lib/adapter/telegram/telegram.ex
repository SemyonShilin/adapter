defmodule Adapter.Telegram do
  @moduledoc """
    The module set webhook for the bots and sends custom messages
  """

  alias Agala.{BotParams, Conn}
  alias Agala.Bot.Handler
  alias Adapter.Telegram.{MessageSender, RequestHandler}
  use Agala.Provider.Telegram, :handler

  use GenServer

  @certificate :agala_telegram |> Application.get_env(:certificate)
  @url         :agala_telegram |> Application.get_env(:url)
  @bot_method  :adapter        |> Application.get_env(Adapter.Telegram) |> Keyword.get(:method)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Adapter.Telegram::#{opts[:name]}"])
  end

  def init(opts) do
    case @bot_method do
      :webhook -> set_webhook(opts)
      :polling -> nil
    end

    {:ok, opts}
  end

  def message_pass(bot_name, hub, message) do
    GenServer.cast(:"#Adapter.Telegram::#{bot_name}", {:message, hub, message})
  end

  def message_pass(bot_name, message) do
    GenServer.cast(:"#Adapter.Telegram::#{bot_name}", {:message, message})
  end

  def handle_cast({:message, message}, state) do
    Handler.handle(message, state)
    {:noreply, state}
  end

  def handle_cast({:message, _hub, %{"data" => %{"messages" => messages, "chat" => %{"id" => id}}} =  _message}, state) do
    messages
    |> RequestHandler.parse_hub_response()
    |> Enum.filter(& &1)
    |> MessageSender.delivery(id, state)

    {:noreply, state}
  end

  def set_webhook(%BotParams{name: bot_name} = params) do
    conn = %Conn{request_bot_params: params} |> Conn.send_to(bot_name)

    HTTPoison.post(
      set_webhook_url(conn),
      webhook_upload_body(conn),
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

  defp create_body(map, opts) when is_map(map) do
    Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
  end

  defp create_body_multipart(map, opts) when is_map(map) do
    multipart =
      map
      |> create_body(opts)
      |> Enum.map(fn
        {key, {:file, file}} ->
          {:file, file, {"form-data", [{:name, key}, {:filename, Path.basename(file)}]}, []}
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
